function Invoke-ServiceNowIdentifyReconcile {
    <#
        .SYNOPSIS
        Creates or updates configuration items using the Identification and Reconciliation API.

        .DESCRIPTION
        Sends a payload to the CMDB Identification and Reconciliation (IRE) API, which de-duplicates
        against identification rules before inserting or updating configuration items and their
        relationships. This is the correct way to ingest CMDB data from an integration, avoiding
        duplicate CIs. Supply the payload as a hashtable with an 'items' array (and optionally
        'relations').

        .PARAMETER InputData
        The IRE payload. A hashtable with an 'items' array describing the CIs to identify and reconcile.

        .PARAMETER DataSource
        An optional data source name recorded against the operation (sysparm_data_source).

        .PARAMETER Instance
        The name of a connected instance to target, instead of the default connection.

        .PARAMETER Connection
        An explicit connection object, overriding the connected session.

        .EXAMPLE
        $payload = @{
            items = @(
                @{
                    className = 'cmdb_ci_linux_server'
                    values    = @{ name = 'app-svr-07'; serial_number = 'SN-12345' }
                }
            )
        }
        Invoke-ServiceNowIdentifyReconcile -InputData $payload -DataSource 'MyIntegration'

        Identify and reconcile a Linux server CI.

        .OUTPUTS
        The reconciliation result, including the affected CI sys_ids.

        .LINK
        https://github.com/deanlongstaff/ServiceNow.API
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [ValidateNotNull()]
        [Alias('Payload', 'Items')]
        [hashtable]$InputData,

        [Parameter()]
        [string]$DataSource,

        [Parameter()]
        [string]$Instance,

        [Parameter()]
        [hashtable]$Connection
    )

    process {
        $ConnectionParams = @{}
        if ($PSBoundParameters.ContainsKey('Connection')) { $ConnectionParams['Connection'] = $Connection }
        if ($PSBoundParameters.ContainsKey('Instance')) { $ConnectionParams['Instance'] = $Instance }

        $QueryParams = @{}
        if ($DataSource) { $QueryParams['sysparm_data_source'] = $DataSource }

        if ($PSCmdlet.ShouldProcess('CMDB', 'Identify and reconcile configuration items')) {
            $Response = Invoke-ServiceNowApi -Method 'POST' -Path 'api/now/identifyreconcile' -Query $QueryParams -Body $InputData @ConnectionParams
            return $Response.result
        }
    }
}
