function Get-ServiceNowCurrentUser {
    <#
        .SYNOPSIS
        Returns the user the current connection is authenticated as.

        .DESCRIPTION
        Calls the ServiceNow current-user endpoint and returns details about the authenticated user,
        including their name, user name and sys_id. Useful for confirming which account a connection is
        using.

        .PARAMETER Instance
        The name of a connected instance to target, instead of the default connection.

        .PARAMETER Connection
        An explicit connection object, overriding the connected session.

        .EXAMPLE
        Get-ServiceNowCurrentUser

        Show who the default connection is authenticated as.

        .EXAMPLE
        Get-ServiceNowCurrentUser -Instance 'prod98765'

        Show the authenticated user for a specific connected instance.

        .OUTPUTS
        The current user details.

        .LINK
        https://github.com/deanlongstaff/ServiceNow.API
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter()]
        [string]$Instance,

        [Parameter()]
        [hashtable]$Connection
    )

    $ConnectionParams = @{}
    if ($PSBoundParameters.ContainsKey('Connection')) { $ConnectionParams['Connection'] = $Connection }
    if ($PSBoundParameters.ContainsKey('Instance')) { $ConnectionParams['Instance'] = $Instance }

    $Response = Invoke-ServiceNowApi -Method 'GET' -Path 'api/now/ui/user/current_user' @ConnectionParams
    return $Response.result
}
