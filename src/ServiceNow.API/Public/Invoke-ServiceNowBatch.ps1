function Invoke-ServiceNowBatch {
    <#
        .SYNOPSIS
        Executes multiple ServiceNow REST requests in a single Batch API call.

        .DESCRIPTION
        Sends several REST requests together using the Batch API, reducing round trips and the impact of
        rate limits. Each request is a hashtable describing the Method, Url and optional Body and
        Headers. The response contains one result per request, with the (decoded) body and status code,
        plus any requests the platform could not service.

        .PARAMETER Request
        One or more request definitions. Each is a hashtable with keys:
          - Method  : GET, POST, PATCH, PUT or DELETE (default GET)
          - Url     : the request path, for example '/api/now/table/incident?sysparm_limit=1'
          - Body    : optional; a string is sent verbatim, any other object is serialised to JSON
          - Headers : optional hashtable of extra headers
          - Id      : optional identifier echoed back in the response (auto-generated when omitted)

        .PARAMETER BatchRequestId
        An identifier for the overall batch. Defaults to a new GUID.

        .PARAMETER Instance
        The name of a connected instance to target, instead of the default connection.

        .PARAMETER Connection
        An explicit connection object, overriding the connected session.

        .EXAMPLE
        $requests = @(
            @{ Id = 'a'; Method = 'GET'; Url = '/api/now/table/incident?sysparm_limit=1' }
            @{ Id = 'b'; Method = 'POST'; Url = '/api/now/table/incident'; Body = @{ short_description = 'Batch created' } }
        )
        Invoke-ServiceNowBatch -Request $requests

        Run a read and a create together.

        .OUTPUTS
        One PSCustomObject per request, with Id, StatusCode, Body, Headers and ExecutionTime.

        .LINK
        https://github.com/deanlongstaff/ServiceNow.API
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [hashtable[]]$Request,

        [Parameter()]
        [string]$BatchRequestId = ([guid]::NewGuid().ToString()),

        [Parameter()]
        [string]$Instance,

        [Parameter()]
        [hashtable]$Connection
    )

    begin {
        $ConnectionParams = @{}
        if ($PSBoundParameters.ContainsKey('Connection')) { $ConnectionParams['Connection'] = $Connection }
        if ($PSBoundParameters.ContainsKey('Instance')) { $ConnectionParams['Instance'] = $Instance }
        $RestRequests = [System.Collections.Generic.List[object]]::new()
        $Counter = 0
    }

    process {
        foreach ($Item in $Request) {
            $Counter++
            $Id = if ($Item.ContainsKey('Id') -and $Item.Id) { [string]$Item.Id } else { "request-$Counter" }
            $Method = if ($Item.ContainsKey('Method') -and $Item.Method) { [string]$Item.Method } else { 'GET' }

            if (-not $Item.ContainsKey('Url') -or [string]::IsNullOrWhiteSpace($Item.Url)) {
                throw "Batch request '$Id' is missing a 'Url'."
            }

            $Entry = @{
                id     = $Id
                method = $Method.ToUpper()
                url    = [string]$Item.Url
            }

            # -- Headers default to JSON; a batch body must be base64-encoded.
            $HeaderList = [System.Collections.Generic.List[object]]::new()
            $HeaderList.Add(@{ name = 'Accept'; value = 'application/json' })
            $HeaderList.Add(@{ name = 'Content-Type'; value = 'application/json' })
            if ($Item.ContainsKey('Headers') -and $Item.Headers) {
                foreach ($Key in $Item.Headers.Keys) {
                    $HeaderList.Add(@{ name = [string]$Key; value = [string]$Item.Headers[$Key] })
                }
            }
            $Entry.headers = $HeaderList.ToArray()

            if ($Item.ContainsKey('Body') -and $null -ne $Item.Body) {
                $BodyString = if ($Item.Body -is [string]) { $Item.Body } else { $Item.Body | ConvertTo-Json -Depth 20 -Compress }
                $Entry.body = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($BodyString))
            }

            $RestRequests.Add($Entry)
        }
    }

    end {
        if ($RestRequests.Count -eq 0) { return }

        $Payload = @{
            batch_request_id = $BatchRequestId
            rest_requests    = $RestRequests.ToArray()
        }

        if (-not $PSCmdlet.ShouldProcess("$($RestRequests.Count) request(s)", 'Invoke ServiceNow batch')) {
            return
        }

        $Response = Invoke-ServiceNowApi -Method 'POST' -Path 'api/now/v1/batch' -Body $Payload @ConnectionParams

        foreach ($Serviced in @($Response.serviced_requests)) {
            $DecodedBody = $null
            if ($Serviced.body) {
                try {
                    $Raw = [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($Serviced.body))
                    try { $DecodedBody = $Raw | ConvertFrom-Json -ErrorAction Stop } catch { $DecodedBody = $Raw }
                }
                catch {
                    $DecodedBody = $Serviced.body
                }
            }

            [pscustomobject]@{
                PSTypeName    = 'ServiceNow.API.BatchResult'
                Id            = $Serviced.id
                StatusCode    = [int]$Serviced.status_code
                Body          = $DecodedBody
                Headers       = $Serviced.headers
                ExecutionTime = $Serviced.execution_time
                Serviced      = $true
            }
        }

        foreach ($Unserviced in @($Response.unserviced_requests)) {
            [pscustomobject]@{
                PSTypeName    = 'ServiceNow.API.BatchResult'
                Id            = $Unserviced
                StatusCode    = $null
                Body          = $null
                Headers       = $null
                ExecutionTime = $null
                Serviced      = $false
            }
        }
    }
}
