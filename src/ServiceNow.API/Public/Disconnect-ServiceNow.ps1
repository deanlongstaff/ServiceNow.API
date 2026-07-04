function Disconnect-ServiceNow {
    <#
        .SYNOPSIS
        Clears one or all stored ServiceNow connections for the current session.

        .DESCRIPTION
        Removes connections stored by Connect-ServiceNow from the module session context, discarding
        any cached credentials and tokens. With -Instance, only that instance is disconnected;
        otherwise every connection is cleared. If the disconnected instance was the default, the most
        recently connected remaining instance becomes the new default.

        .PARAMETER Instance
        The name of a single connected instance to disconnect. When omitted, all connections are cleared.

        .EXAMPLE
        Disconnect-ServiceNow

        Disconnect from every instance.

        .EXAMPLE
        Disconnect-ServiceNow -Instance 'dev12345'

        Disconnect from a single instance, leaving any others connected.

        .OUTPUTS
        None.

        .LINK
        https://github.com/deanlongstaff/ServiceNow.API
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Position = 0)]
        [string]$Instance
    )

    if ($script:ServiceNowConnections.Count -eq 0) {
        Write-Verbose 'No active ServiceNow connection to disconnect.'
        return
    }

    if ($PSBoundParameters.ContainsKey('Instance') -and -not [string]::IsNullOrWhiteSpace($Instance)) {
        $Name = (ConvertTo-ServiceNowInstanceName -Instance $Instance).Name
        if (-not $script:ServiceNowConnections.ContainsKey($Name)) {
            Write-Verbose "Not connected to ServiceNow instance '$Name'; nothing to disconnect."
            return
        }
        if ($PSCmdlet.ShouldProcess("ServiceNow instance '$Name'", 'Disconnect')) {
            $script:ServiceNowConnections.Remove($Name)
            if ($script:ServiceNowDefaultInstance -eq $Name) {
                # -- Promote the most recently connected remaining instance to default.
                $script:ServiceNowDefaultInstance = $script:ServiceNowConnections.Keys | Select-Object -Last 1
            }
            Write-Verbose "Disconnected from ServiceNow instance '$Name'."
        }
        return
    }

    if ($PSCmdlet.ShouldProcess('all ServiceNow connections', 'Disconnect')) {
        $script:ServiceNowConnections.Clear()
        $script:ServiceNowDefaultInstance = $null
        Write-Verbose 'Disconnected from all ServiceNow instances.'
    }
}
