function Import-ServiceNowRecord {
    <#
        .SYNOPSIS
        Sends a record to a ServiceNow import set staging table.

        .DESCRIPTION
        Posts data to an import set staging table using the Import Set API. ServiceNow runs the table's
        transform maps and returns the result, including the sys_id and table of any target records that
        were created or updated. Use this for integrations that load data through an import set rather
        than writing directly to a table.

        .PARAMETER StagingTable
        The import set staging table, for example 'u_imp_user'.

        .PARAMETER InputData
        A hashtable of staging-table field names and values.

        .PARAMETER PassThru
        Return the import result (including transform outcomes).

        .PARAMETER Instance
        The name of a connected instance to target, instead of the default connection.

        .PARAMETER Connection
        An explicit connection object, overriding the connected session.

        .EXAMPLE
        Import-ServiceNowRecord -StagingTable u_imp_user -InputData @{ u_user_name = 'jdoe'; u_email = 'jdoe@example.com' } -PassThru

        Load a user through an import set and see the transform result.

        .OUTPUTS
        None by default, or the import result when -PassThru is used.

        .LINK
        https://github.com/deanlongstaff/ServiceNow.API
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$StagingTable,

        [Parameter(Mandatory = $true, Position = 1, ValueFromPipeline = $true)]
        [ValidateNotNull()]
        [Alias('Values', 'Properties')]
        [hashtable]$InputData,

        [Parameter()]
        [switch]$PassThru,

        [Parameter()]
        [string]$Instance,

        [Parameter()]
        [hashtable]$Connection
    )

    process {
        $ConnectionParams = @{}
        if ($PSBoundParameters.ContainsKey('Connection')) { $ConnectionParams['Connection'] = $Connection }
        if ($PSBoundParameters.ContainsKey('Instance')) { $ConnectionParams['Instance'] = $Instance }

        if ($PSCmdlet.ShouldProcess($StagingTable, 'Import ServiceNow record')) {
            $Response = Invoke-ServiceNowApi -Method 'POST' -Path "api/now/import/$StagingTable" -Body $InputData @ConnectionParams
            if ($PassThru) { return $Response.result }
        }
    }
}
