function New-ServiceNowAuthHeader {
    <#
        .SYNOPSIS
        Builds the Authorization header for a ServiceNow request.

        .DESCRIPTION
        Internal helper. Produces the correct Authorization header for the connection's authentication
        type. For Basic authentication the credential is encoded as a base64 'user:password' string.
        For OAuth, a Bearer token is used; if the cached access token has expired (or is about to), it
        is transparently refreshed using the stored refresh token, falling back to the password grant.
        The refreshed token is written back into the connection so subsequent calls reuse it.

        .PARAMETER Connection
        The resolved connection hashtable.

        .PARAMETER ForceRefresh
        Force an OAuth token refresh even if the cached token has not yet expired. Used to recover from
        an unexpected 401 response.

        .OUTPUTS
        System.Collections.Hashtable containing the Authorization header.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Builds an authorization header and refreshes a cached token; exposes no user-facing state change.')]
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Connection,

        [switch]$ForceRefresh
    )

    switch ($Connection.AuthType) {
        'Basic' {
            $Cred = $Connection.Credential
            $Pair = '{0}:{1}' -f $Cred.UserName, $Cred.GetNetworkCredential().Password
            $Encoded = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Pair))
            return @{ Authorization = "Basic $Encoded" }
        }

        'OAuth' {
            # -- Refresh when forced, when there is no token yet, or when within 30s of expiry.
            $TokenMissing = ($null -eq $Connection.AccessToken) -or ($null -eq $Connection.TokenExpiry)
            $TokenExpiring = (-not $TokenMissing) -and ((Get-Date) -ge $Connection.TokenExpiry.AddSeconds(-30))
            $NeedsRefresh = $ForceRefresh -or $TokenMissing -or $TokenExpiring

            if ($NeedsRefresh) {
                $TokenParams = @{
                    BaseUrl      = $Connection.BaseUrl
                    ClientId     = $Connection.ClientId
                    ClientSecret = $Connection.ClientSecret
                }
                if ($Connection.Proxy) {
                    $TokenParams.Proxy = $Connection.Proxy
                    if ($Connection.ProxyCredential) { $TokenParams.ProxyCredential = $Connection.ProxyCredential }
                }

                # -- Prefer the refresh grant; fall back to the password grant when it is unavailable
                #    or rejected (for example after the refresh token itself has expired).
                $Token = $null
                if ($Connection.RefreshToken -and -not $ForceRefresh) {
                    try {
                        $Token = Get-ServiceNowToken @TokenParams -RefreshToken $Connection.RefreshToken
                    }
                    catch {
                        Write-Verbose 'ServiceNow OAuth refresh grant failed; falling back to the password grant.'
                    }
                }
                if (-not $Token) {
                    $Token = Get-ServiceNowToken @TokenParams -Credential $Connection.Credential
                }

                $Connection.AccessToken = $Token.access_token
                if ($Token.PSObject.Properties.Name -contains 'refresh_token' -and $Token.refresh_token) {
                    $Connection.RefreshToken = $Token.refresh_token
                }
                $ExpiresIn = if ($Token.expires_in) { [double]$Token.expires_in } else { 1800 }
                $Connection.TokenExpiry = (Get-Date).AddSeconds($ExpiresIn)
            }

            return @{ Authorization = "Bearer $($Connection.AccessToken)" }
        }

        'Token' {
            $PlainToken = [System.Net.NetworkCredential]::new('', $Connection.AccessTokenSecure).Password
            return @{ Authorization = "Bearer $PlainToken" }
        }

        default {
            throw "Unknown ServiceNow authentication type '$($Connection.AuthType)'."
        }
    }
}
