function Add-ServiceNowWorkNote {
    <#
        .SYNOPSIS
        Adds a work note to a record.

        .DESCRIPTION
        Appends text to the 'work_notes' journal field of a record on any task table. Work notes are
        internal (not shown to the customer). Records can be piped in from a Get cmdlet.

        .PARAMETER Table
        The table containing the record, for example 'incident'.

        .PARAMETER Sys_ID
        The sys_id of the record to add the work note to.

        .PARAMETER Text
        The work note text to add.

        .PARAMETER PassThru
        Return the updated record.

        .PARAMETER Instance
        The name of a connected instance to target, instead of the default connection.

        .PARAMETER Connection
        An explicit connection object, overriding the connected session.

        .EXAMPLE
        Add-ServiceNowWorkNote -Table incident -Sys_ID $sysId -Text 'Restarted the print spooler.'

        Add an internal work note to an incident.

        .EXAMPLE
        Get-ServiceNowIncident -Query 'active=true' | Add-ServiceNowWorkNote -Text 'Bulk triage complete.'

        .OUTPUTS
        None by default, or the updated record when -PassThru is used.

        .LINK
        https://github.com/deanlongstaff/ServiceNow.API
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([pscustomobject])]
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
        [ValidateNotNullOrEmpty()]
        [Alias('WorkNote', 'Value')]
        [string]$Text,

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

        if ($PSCmdlet.ShouldProcess("$Table/$Sys_ID", 'Add work note')) {
            Set-ServiceNowRecord -Table $Table -Sys_ID $Sys_ID -InputData @{ work_notes = $Text } -PassThru:$PassThru -Confirm:$false @ConnectionParams
        }
    }
}
