function Resolve-ServiceNowConnection {
    <#
        .SYNOPSIS
        Resolves the ServiceNow connection to use for a request.

        .DESCRIPTION
        Internal helper. Resolution order:
          1. An explicitly supplied -Connection object always wins.
          2. Otherwise, a named -Instance is looked up among the connected instances; if that instance
             is not connected, a terminating error is thrown that lists the instances that are.
          3. Otherwise the current default connection (the most recently connected instance) is used.
          4. If none of the above apply, a terminating error is thrown.

        .PARAMETER Connection
        An explicit connection object (as returned by Connect-ServiceNow -PassThru) that overrides
        everything else, if supplied.

        .PARAMETER Instance
        The name of a connected instance to use. Accepts the short name, a hostname or a URL; it is
        normalised the same way Connect-ServiceNow normalises it.

        .OUTPUTS
        System.Collections.Hashtable describing the connection.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [hashtable]$Connection,

        [string]$Instance
    )

    if ($Connection -and $Connection.Count -gt 0) {
        $Resolved = $Connection
    }
    elseif (-not [string]::IsNullOrWhiteSpace($Instance)) {
        $Name = (ConvertTo-ServiceNowInstanceName -Instance $Instance).Name
        if ($script:ServiceNowConnections.ContainsKey($Name)) {
            $Resolved = $script:ServiceNowConnections[$Name]
        }
        else {
            $Connected = ($script:ServiceNowConnections.Keys | Sort-Object) -join ', '
            if ([string]::IsNullOrWhiteSpace($Connected)) { $Connected = '(none)' }
            throw "Not connected to ServiceNow instance '$Name'. Connected instances: $Connected. Run Connect-ServiceNow -Instance '$Name' first."
        }
    }
    elseif ($script:ServiceNowDefaultInstance -and $script:ServiceNowConnections.ContainsKey($script:ServiceNowDefaultInstance)) {
        $Resolved = $script:ServiceNowConnections[$script:ServiceNowDefaultInstance]
    }
    else {
        throw 'Not connected to ServiceNow. Run Connect-ServiceNow first, or pass -Connection or -Instance to this command.'
    }

    if ([string]::IsNullOrWhiteSpace($Resolved.BaseUrl)) {
        throw 'The ServiceNow connection is missing a base URL. Reconnect with Connect-ServiceNow.'
    }

    return $Resolved
}
