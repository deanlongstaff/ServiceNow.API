function Add-ServiceNowComment {
    <#
        .SYNOPSIS
        Adds a customer-visible comment to a record.

        .DESCRIPTION
        Appends text to the 'comments' journal field of a record on any task table. Comments are
        visible to the caller/customer. Records can be piped in from a Get cmdlet.

        .PARAMETER Table
        The table containing the record, for example 'incident'.

        .PARAMETER Sys_ID
        The sys_id of the record to comment on.

        .PARAMETER Text
        The comment text to add.

        .PARAMETER PassThru
        Return the updated record.

        .PARAMETER Instance
        The name of a connected instance to target, instead of the default connection.

        .PARAMETER Connection
        An explicit connection object, overriding the connected session.

        .EXAMPLE
        Add-ServiceNowComment -Table incident -Sys_ID $sysId -Text 'We are investigating and will update you shortly.'

        Add a customer-visible comment to an incident.

        .EXAMPLE
        Get-ServiceNowIncident -Number 'INC0010023' | Add-ServiceNowComment -Text 'Resolved, please confirm.'

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
        [Alias('Comment', 'Value')]
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

        if ($PSCmdlet.ShouldProcess("$Table/$Sys_ID", 'Add comment')) {
            Set-ServiceNowRecord -Table $Table -Sys_ID $Sys_ID -InputData @{ comments = $Text } -PassThru:$PassThru -Confirm:$false @ConnectionParams
        }
    }
}
