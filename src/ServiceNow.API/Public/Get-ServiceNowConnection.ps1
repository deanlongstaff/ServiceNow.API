function Get-ServiceNowConnection {
    <#
        .SYNOPSIS
        Returns one or all current ServiceNow connection contexts.

        .DESCRIPTION
        Returns a summary of a connection established by Connect-ServiceNow, including the instance,
        base URL and authentication type. Secrets are never returned: passwords and tokens are omitted,
        and only the connected user name is shown.

        With no parameters the current default connection is returned (or $null when none). Use
        -Instance to return a specific connection, or -All to list every connected instance. The
        IsDefault property indicates which connection is used when a cmdlet is called without -Instance
        or -Connection.

        .PARAMETER Instance
        The name of a connected instance to return.

        .PARAMETER All
        Return a summary for every connected instance.

        .EXAMPLE
        Get-ServiceNowConnection

        Return the current default connection.

        .EXAMPLE
        Get-ServiceNowConnection -All

        List every connected instance.

        .OUTPUTS
        System.Management.Automation.PSCustomObject, or $null when not connected.

        .LINK
        https://github.com/deanlongstaff/ServiceNow.API
    #>
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    [OutputType([pscustomobject])]
    param(
        [Parameter(ParameterSetName = 'Instance', Position = 0)]
        [string]$Instance,

        [Parameter(ParameterSetName = 'All')]
        [switch]$All
    )

    # -- Project a stored connection into a summary that never exposes secrets.
    function ConvertTo-Summary {
        param($Ctx)
        [pscustomobject]@{
            PSTypeName        = 'ServiceNow.API.Connection'
            Instance          = $Ctx.Instance
            BaseUrl           = $Ctx.BaseUrl
            AuthType          = $Ctx.AuthType
            UserName          = if ($Ctx.Credential) { $Ctx.Credential.UserName } else { $null }
            IsDefault         = ($Ctx.Instance -eq $script:ServiceNowDefaultInstance)
            TokenExpiry       = $Ctx.TokenExpiry
            MaxRetry          = $Ctx.MaxRetry
            RetryDelaySeconds = $Ctx.RetryDelaySeconds
            TimeoutSeconds    = $Ctx.TimeoutSeconds
        }
    }

    if ($All) {
        foreach ($Key in ($script:ServiceNowConnections.Keys | Sort-Object)) {
            ConvertTo-Summary -Ctx $script:ServiceNowConnections[$Key]
        }
        return
    }

    if (-not [string]::IsNullOrWhiteSpace($Instance)) {
        $Name = (ConvertTo-ServiceNowInstanceName -Instance $Instance).Name
        if (-not $script:ServiceNowConnections.ContainsKey($Name)) {
            Write-Verbose "No active ServiceNow connection for instance '$Name'."
            return $null
        }
        return ConvertTo-Summary -Ctx $script:ServiceNowConnections[$Name]
    }

    # -- Default: the current default connection.
    if (-not $script:ServiceNowDefaultInstance -or -not $script:ServiceNowConnections.ContainsKey($script:ServiceNowDefaultInstance)) {
        Write-Verbose 'No active ServiceNow connection.'
        return $null
    }
    return ConvertTo-Summary -Ctx $script:ServiceNowConnections[$script:ServiceNowDefaultInstance]
}
