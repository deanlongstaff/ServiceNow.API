function Invoke-ServiceNowApi {
    <#
        .SYNOPSIS
        Sends an authenticated request to the ServiceNow REST API.

        .DESCRIPTION
        Internal request engine used by every public cmdlet. It resolves the connection, builds the
        authorization header (refreshing OAuth tokens as needed), assembles the URI and query string,
        serialises the request body to JSON, and parses the response.

        Resilience is built in and always on:
          - HTTP 401 triggers a single OAuth token refresh and retry.
          - HTTP 429 (rate limited) waits for the Retry-After period (or an exponential backoff) and
            retries, up to the connection's MaxRetry.
          - HTTP 502, 503 and 504 (transient server errors) are retried with exponential backoff.
        All other failures throw a single descriptive terminating error that carries the HTTP status
        code in the exception's Data dictionary under 'ServiceNowStatusCode'.

        .PARAMETER Method
        The HTTP method.

        .PARAMETER Path
        The request path appended to the instance base URL, for example 'api/now/table/incident'. An
        absolute URL is also accepted and used as-is.

        .PARAMETER Query
        Optional hashtable of query-string parameters. Values are URL-encoded automatically.

        .PARAMETER Body
        Optional request body. A string is sent verbatim; any other object is serialised to JSON.

        .PARAMETER ContentType
        The request content type. Defaults to 'application/json'.

        .PARAMETER Headers
        Optional additional headers merged over the default Accept and Authorization headers.

        .PARAMETER Connection
        An explicit connection object, overriding the connected session.

        .PARAMETER Instance
        The name of a connected instance to use instead of the default connection.

        .PARAMETER Raw
        Return the raw response bytes instead of parsed JSON (used for attachment downloads).

        .PARAMETER OutFile
        Write the response body to this path instead of returning it.

        .PARAMETER InFile
        Send the contents of this file as the request body (used for attachment uploads).

        .OUTPUTS
        The parsed JSON response object, System.Byte[] when -Raw is used, or nothing when -OutFile is used.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet('GET', 'POST', 'PATCH', 'PUT', 'DELETE')]
        [string]$Method,

        [Parameter(Mandatory = $true)]
        [string]$Path,

        [hashtable]$Query,

        [object]$Body,

        [string]$ContentType = 'application/json',

        [hashtable]$Headers,

        [hashtable]$Connection,

        [string]$Instance,

        [switch]$Raw,

        [string]$OutFile,

        [string]$InFile
    )

    $Ctx = Resolve-ServiceNowConnection -Connection $Connection -Instance $Instance

    # -- Build the URI (accept absolute URLs verbatim, otherwise prepend the instance base URL).
    if ($Path -match '^https?://') {
        $Uri = $Path
    }
    else {
        $Uri = '{0}/{1}' -f $Ctx.BaseUrl, $Path.TrimStart('/')
    }

    if ($Query -and $Query.Count -gt 0) {
        $Pairs = foreach ($Key in $Query.Keys) {
            '{0}={1}' -f $Key, [uri]::EscapeDataString([string]$Query[$Key])
        }
        $Separator = if ($Uri -match '\?') { '&' } else { '?' }
        $Uri = $Uri + $Separator + ($Pairs -join '&')
    }

    # -- Serialise the body once. A pre-built string (e.g. a batch payload) is sent verbatim.
    $RequestBody = $null
    if ($PSBoundParameters.ContainsKey('Body') -and $null -ne $Body) {
        if ($Body -is [string]) {
            $RequestBody = $Body
        }
        else {
            $RequestBody = $Body | ConvertTo-Json -Depth 20 -Compress
        }
    }

    $MaxRetry = if ($null -ne $Ctx.MaxRetry) { [int]$Ctx.MaxRetry } else { 5 }
    $BaseDelay = if ($null -ne $Ctx.RetryDelaySeconds) { [int]$Ctx.RetryDelaySeconds } else { 2 }
    $MaxTransientBackoff = 32
    $MaxRateLimitWait = 120

    $Attempt = 0
    $TokenRefreshed = $false

    while ($true) {
        $RequestHeaders = New-ServiceNowAuthHeader -Connection $Ctx
        $RequestHeaders['Accept'] = 'application/json'
        if ($Headers) {
            foreach ($Key in $Headers.Keys) { $RequestHeaders[$Key] = $Headers[$Key] }
        }

        $RequestParams = @{
            Uri         = $Uri
            Method      = $Method
            Headers     = $RequestHeaders
            ErrorAction = 'Stop'
        }
        if ($null -ne $RequestBody) {
            $RequestParams.Body = $RequestBody
            $RequestParams.ContentType = $ContentType
        }
        if ($InFile) {
            $RequestParams.InFile = $InFile
            $RequestParams.ContentType = $ContentType
        }
        if ($Ctx.TimeoutSeconds -and [int]$Ctx.TimeoutSeconds -gt 0) {
            $RequestParams.TimeoutSec = [int]$Ctx.TimeoutSeconds
        }
        if ($Ctx.Proxy) {
            $RequestParams.Proxy = $Ctx.Proxy
            if ($Ctx.ProxyCredential) { $RequestParams.ProxyCredential = $Ctx.ProxyCredential }
        }

        try {
            if ($Raw -or $OutFile) {
                if ($OutFile) { $RequestParams.OutFile = $OutFile }
                $Response = Invoke-WebRequest @RequestParams -UseBasicParsing
                if ($OutFile) { return }
                # -- Return the byte array as a single object so the pipeline does not unroll it.
                return , $Response.Content
            }

            return Invoke-RestMethod @RequestParams
        }
        catch {
            $Detail = Get-ServiceNowResponseDetail -ErrorRecord $_
            $StatusCode = $Detail.StatusCode

            # -- 401 Unauthorized: refresh the OAuth token once and retry.
            if ($StatusCode -eq 401 -and -not $TokenRefreshed -and $Ctx.AuthType -eq 'OAuth') {
                Write-Verbose 'ServiceNow returned 401. Refreshing the OAuth token and retrying.'
                $TokenRefreshed = $true
                $null = New-ServiceNowAuthHeader -Connection $Ctx -ForceRefresh
                continue
            }

            # -- 429 Too Many Requests: honour rate limiting.
            if ($StatusCode -eq 429) {
                if ($MaxRetry -le 0 -or $Attempt -ge $MaxRetry) {
                    throw (New-ServiceNowError -Method $Method -Uri $Uri -Detail $Detail)
                }
                $Attempt++
                $Wait = if ($Detail.RetryAfterSeconds -and $Detail.RetryAfterSeconds -gt 0) {
                    $Detail.RetryAfterSeconds
                }
                else {
                    [Math]::Pow(2, $Attempt) * $BaseDelay
                }
                $Wait = [int][Math]::Ceiling([Math]::Min($Wait, $MaxRateLimitWait))
                Write-Warning "ServiceNow rate limit hit (HTTP 429). Waiting $Wait second(s) before retry $Attempt of $MaxRetry."
                Start-Sleep -Seconds $Wait
                continue
            }

            # -- 502/503/504 transient server errors: exponential backoff.
            if ($StatusCode -in 502, 503, 504) {
                if ($MaxRetry -le 0 -or $Attempt -ge $MaxRetry) {
                    throw (New-ServiceNowError -Method $Method -Uri $Uri -Detail $Detail)
                }
                $Attempt++
                $Wait = [int][Math]::Min([Math]::Pow(2, $Attempt) * $BaseDelay, $MaxTransientBackoff)
                Write-Warning "Transient HTTP $StatusCode from ServiceNow. Retrying in $Wait second(s) (attempt $Attempt of $MaxRetry)."
                Start-Sleep -Seconds $Wait
                continue
            }

            throw (New-ServiceNowError -Method $Method -Uri $Uri -Detail $Detail -InnerException $_.Exception)
        }
    }
}
