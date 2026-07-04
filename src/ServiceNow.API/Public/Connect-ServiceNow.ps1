function Connect-ServiceNow {
    <#
        .SYNOPSIS
        Establishes a ServiceNow connection for the current session.

        .DESCRIPTION
        Stores a ServiceNow connection in the module session context, which every other ServiceNow.API
        cmdlet uses by default. Three authentication methods are supported:

          - Basic: an instance and a credential.
          - OAuth: an instance, a credential and an OAuth application client id and secret. An access
            token is requested immediately and refreshed automatically before it expires.
          - Token: an instance and a pre-issued OAuth access token.

        Credentials and tokens are held in memory only and are never written to disk.

        You can connect to more than one instance at once. Each connection is stored under its instance
        name, and the most recently connected instance becomes the session default. Any cmdlet can then
        target a specific instance with -Instance (by name) or -Connection (with an object from
        -PassThru); with neither, the default is used.

        Rate-limit and transient-error handling is always on: HTTP 429 responses are retried after the
        Retry-After delay, and HTTP 502/503/504 are retried with exponential backoff, up to -MaxRetry
        attempts.

        .PARAMETER Instance
        The ServiceNow instance. Accepts the short instance name ('dev12345'), a hostname
        ('dev12345.service-now.com') or a full URL. It is normalised to the instance base URL.

        .PARAMETER Credential
        The credential used to authenticate. For Basic this is used on every request; for OAuth it is
        the integration user for the password grant.

        .PARAMETER ClientId
        The OAuth application client id. Supplying this (with -ClientSecret) selects OAuth.

        .PARAMETER ClientSecret
        The OAuth application client secret, as a SecureString.

        .PARAMETER AccessToken
        A pre-issued OAuth access token, as a SecureString. Selects token authentication.

        .PARAMETER MaxRetry
        Maximum number of retries for rate-limited and transient failures. Defaults to 5. Set to 0 to
        disable automatic retries.

        .PARAMETER RetryDelaySeconds
        Base delay, in seconds, for the exponential backoff between retries. Defaults to 2.

        .PARAMETER TimeoutSeconds
        Optional per-request timeout in seconds. When 0 (the default) no explicit timeout is applied.

        .PARAMETER Proxy
        Optional proxy URL for all requests.

        .PARAMETER ProxyCredential
        Optional credential for an authenticated proxy.

        .PARAMETER PassThru
        Return the resulting (masked) connection context.

        .EXAMPLE
        Connect-ServiceNow -Instance 'dev12345' -Credential (Get-Credential)

        Connects with Basic authentication.

        .EXAMPLE
        $secret = Read-Host 'Client secret' -AsSecureString
        Connect-ServiceNow -Instance 'dev12345' -Credential $cred -ClientId $id -ClientSecret $secret

        Connects with OAuth and requests an access token immediately.

        .OUTPUTS
        None by default, or a PSCustomObject describing the connection when -PassThru is used.

        .LINK
        https://github.com/deanlongstaff/ServiceNow.API
    #>
    [CmdletBinding(DefaultParameterSetName = 'Basic', SupportsShouldProcess = $true)]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [Alias('Url', 'Server')]
        [string]$Instance,

        [Parameter(Mandatory = $true, ParameterSetName = 'Basic')]
        [Parameter(Mandatory = $true, ParameterSetName = 'OAuth')]
        [ValidateNotNull()]
        [pscredential]$Credential,

        [Parameter(Mandatory = $true, ParameterSetName = 'OAuth')]
        [ValidateNotNullOrEmpty()]
        [string]$ClientId,

        [Parameter(Mandatory = $true, ParameterSetName = 'OAuth')]
        [ValidateNotNull()]
        [securestring]$ClientSecret,

        [Parameter(Mandatory = $true, ParameterSetName = 'Token')]
        [ValidateNotNull()]
        [securestring]$AccessToken,

        [Parameter()]
        [ValidateRange(0, 20)]
        [int]$MaxRetry = 5,

        [Parameter()]
        [ValidateRange(1, 60)]
        [int]$RetryDelaySeconds = 2,

        [Parameter()]
        [ValidateRange(0, 3600)]
        [int]$TimeoutSeconds = 0,

        [Parameter()]
        [string]$Proxy,

        [Parameter()]
        [pscredential]$ProxyCredential,

        [switch]$PassThru
    )

    # -- Normalise the instance to a canonical name and base URL.
    $Normalised = ConvertTo-ServiceNowInstanceName -Instance $Instance
    $BaseUrl = $Normalised.BaseUrl
    $ShortName = $Normalised.Name

    if (-not $PSCmdlet.ShouldProcess($BaseUrl, "Connect using $($PSCmdlet.ParameterSetName) authentication")) {
        return
    }

    $Context = @{
        BaseUrl           = $BaseUrl
        Instance          = $ShortName
        AuthType          = $PSCmdlet.ParameterSetName
        MaxRetry          = $MaxRetry
        RetryDelaySeconds = $RetryDelaySeconds
        TimeoutSeconds    = $TimeoutSeconds
    }
    if ($Proxy) { $Context.Proxy = $Proxy }
    if ($ProxyCredential) { $Context.ProxyCredential = $ProxyCredential }

    switch ($PSCmdlet.ParameterSetName) {
        'Basic' {
            $Context.Credential = $Credential
        }
        'OAuth' {
            $Context.Credential = $Credential
            $Context.ClientId = $ClientId
            $Context.ClientSecret = $ClientSecret

            # -- Obtain a token now so bad credentials fail fast; New-ServiceNowAuthHeader caches it.
            try {
                $Token = Get-ServiceNowToken -BaseUrl $BaseUrl -ClientId $ClientId -ClientSecret $ClientSecret -Credential $Credential -Proxy $Context.Proxy -ProxyCredential $Context.ProxyCredential
            }
            catch {
                throw "Unable to obtain a ServiceNow OAuth access token: $($_.Exception.Message)"
            }
            if (-not $Token.access_token) {
                throw 'ServiceNow did not return an OAuth access token.'
            }
            $Context.AccessToken = $Token.access_token
            if ($Token.refresh_token) { $Context.RefreshToken = $Token.refresh_token }
            $ExpiresIn = if ($Token.expires_in) { [double]$Token.expires_in } else { 1800 }
            $Context.TokenExpiry = (Get-Date).AddSeconds($ExpiresIn)
        }
        'Token' {
            $Context.AccessTokenSecure = $AccessToken
        }
    }

    # -- Register the connection (keyed by instance name) and make it the default for this session.
    $script:ServiceNowConnections[$ShortName] = $Context
    $script:ServiceNowDefaultInstance = $ShortName
    Write-Verbose "Connected to ServiceNow instance '$ShortName' ($BaseUrl) using $($PSCmdlet.ParameterSetName) authentication."

    if ($PassThru) {
        return Get-ServiceNowConnection -Instance $ShortName
    }
}
