function Set-ServiceNowRecord {
    <#
        .SYNOPSIS
        Updates an existing record in a ServiceNow table.

        .DESCRIPTION
        Updates a record on any table using the Table API (HTTP PATCH). Supply the sys_id of the record
        and a hashtable of the fields to change. Only the supplied fields are modified. The updated
        record can be returned with -PassThru.

        This cmdlet is also available under the alias Update-ServiceNowRecord.

        .PARAMETER Table
        The table containing the record, for example 'incident'.

        .PARAMETER Sys_ID
        The sys_id of the record to update.

        .PARAMETER InputData
        A hashtable of field names and values to change.

        .PARAMETER InputDisplayValue
        Treat the supplied values as display values rather than raw values
        (sends sysparm_input_display_value=true).

        .PARAMETER PassThru
        Return the updated record.

        .PARAMETER Instance
        The name of a connected instance to target, instead of the default connection.

        .PARAMETER Connection
        An explicit connection object, overriding the connected session.

        .EXAMPLE
        Set-ServiceNowRecord -Table incident -Sys_ID $sysId -InputData @{ state = 6; close_notes = 'Resolved' }

        Update an incident's state and close notes.

        .EXAMPLE
        Get-ServiceNowRecord -Table incident -Query 'active=true' | Set-ServiceNowRecord -InputData @{ work_notes = 'Bulk update' }

        Update every active incident via the pipeline.

        .OUTPUTS
        None by default, or the updated record when -PassThru is used.

        .LINK
        https://github.com/deanlongstaff/ServiceNow.API
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([pscustomobject])]
    [Alias('Update-ServiceNowRecord')]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('sys_class_name')]
        [string]$Table,

        [Parameter(Mandatory = $true, Position = 1, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('SysId', 'Id')]
        [string]$Sys_ID,

        [Parameter(Mandatory = $true, Position = 2)]
        [ValidateNotNull()]
        [Alias('Values', 'Properties')]
        [hashtable]$InputData,

        [Parameter()]
        [switch]$InputDisplayValue,

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

        $QueryParams = @{}
        if ($InputDisplayValue) { $QueryParams['sysparm_input_display_value'] = 'true' }

        if ($PSCmdlet.ShouldProcess("$Table/$Sys_ID", 'Update ServiceNow record')) {
            $Response = Invoke-ServiceNowApi -Method 'PATCH' -Path "api/now/table/$Table/$Sys_ID" -Query $QueryParams -Body $InputData @ConnectionParams
            if ($PassThru) { return $Response.result }
        }
    }
}
