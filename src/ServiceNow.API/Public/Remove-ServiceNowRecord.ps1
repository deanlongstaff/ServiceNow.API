function Remove-ServiceNowRecord {
    <#
        .SYNOPSIS
        Deletes a record from a ServiceNow table.

        .DESCRIPTION
        Deletes a record on any table using the Table API (HTTP DELETE). Records can be piped in from
        Get-ServiceNowRecord. This is a destructive operation and prompts for confirmation by default.

        .PARAMETER Table
        The table containing the record, for example 'incident'.

        .PARAMETER Sys_ID
        The sys_id of the record to delete.

        .PARAMETER Instance
        The name of a connected instance to target, instead of the default connection.

        .PARAMETER Connection
        An explicit connection object, overriding the connected session.

        .EXAMPLE
        Remove-ServiceNowRecord -Table incident -Sys_ID $sysId

        Delete a single incident, prompting for confirmation.

        .EXAMPLE
        Get-ServiceNowRecord -Table incident -Query 'state=7' | Remove-ServiceNowRecord -Confirm:$false

        Delete every closed incident without prompting.

        .OUTPUTS
        None.

        .LINK
        https://github.com/deanlongstaff/ServiceNow.API
    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('sys_class_name')]
        [string]$Table,

        [Parameter(Mandatory = $true, Position = 1, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('SysId', 'Id')]
        [string]$Sys_ID,

        [Parameter()]
        [string]$Instance,

        [Parameter()]
        [hashtable]$Connection
    )

    process {
        $ConnectionParams = @{}
        if ($PSBoundParameters.ContainsKey('Connection')) { $ConnectionParams['Connection'] = $Connection }
        if ($PSBoundParameters.ContainsKey('Instance')) { $ConnectionParams['Instance'] = $Instance }

        if ($PSCmdlet.ShouldProcess("$Table/$Sys_ID", 'Delete ServiceNow record')) {
            $null = Invoke-ServiceNowApi -Method 'DELETE' -Path "api/now/table/$Table/$Sys_ID" @ConnectionParams
        }
    }
}
