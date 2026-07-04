function Get-ServiceNowToken {
    <#
        .SYNOPSIS
        Requests an OAuth 2.0 access token from ServiceNow.

        .DESCRIPTION
        Internal helper for OAuth authentication. Uses the resource owner password credentials grant to
        obtain an access token, or the refresh token grant to renew an existing session without
        re-sending the user's password. The returned object is the raw ServiceNow token response
        (access_token, refresh_token, expires_in and so on).

        .PARAMETER BaseUrl
        The instance base URL, for example 'https://dev12345.service-now.com'.

        .PARAMETER ClientId
        The OAuth application client id.

        .PARAMETER ClientSecret
        The OAuth application client secret, as a SecureString.

        .PARAMETER Credential
        The integration user's credential. Required for the password grant.

        .PARAMETER RefreshToken
        An existing refresh token. When supplied, the refresh token grant is used instead of the
        password grant.

        .PARAMETER Proxy
        Optional proxy URL used for the token request.

        .PARAMETER ProxyCredential
        Optional credential for an authenticated proxy.

        .OUTPUTS
        The parsed OAuth token response object.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$BaseUrl,

        [Parameter(Mandatory = $true)]
        [string]$ClientId,

        [Parameter(Mandatory = $true)]
        [securestring]$ClientSecret,

        [Parameter()]
        [pscredential]$Credential,

        [Parameter()]
        [string]$RefreshToken,

        [Parameter()]
        [string]$Proxy,

        [Parameter()]
        [pscredential]$ProxyCredential
    )

    $Body = @{
        client_id     = $ClientId
        client_secret = [System.Net.NetworkCredential]::new('', $ClientSecret).Password
    }

    if ($RefreshToken) {
        $Body.grant_type = 'refresh_token'
        $Body.refresh_token = $RefreshToken
    }
    else {
        if (-not $Credential) {
            throw 'A credential is required to obtain a ServiceNow OAuth token using the password grant.'
        }
        $Body.grant_type = 'password'
        $Body.username = $Credential.UserName
        $Body.password = $Credential.GetNetworkCredential().Password
    }

    $RequestParams = @{
        Uri         = "$BaseUrl/oauth_token.do"
        Method      = 'POST'
        Body        = $Body
        ContentType = 'application/x-www-form-urlencoded'
        ErrorAction = 'Stop'
    }
    if ($Proxy) {
        $RequestParams.Proxy = $Proxy
        if ($ProxyCredential) { $RequestParams.ProxyCredential = $ProxyCredential }
    }

    return Invoke-RestMethod @RequestParams
}
