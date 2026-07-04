function Get-ServiceNowJournalEntry {
    <#
        .SYNOPSIS
        Retrieves the comments and work notes for a record.

        .DESCRIPTION
        Reads journal entries (comments and work notes) for a record from the sys_journal_field table,
        newest first. Use -Type to return only comments or only work notes. Each entry includes the
        text, the field it came from, and who added it and when.

        .PARAMETER Sys_ID
        The sys_id of the record whose journal entries you want.

        .PARAMETER Type
        Which entries to return: 'comments', 'work_notes' or 'all' (the default).

        .PARAMETER Limit
        The maximum number of entries to return.

        .PARAMETER Instance
        The name of a connected instance to target, instead of the default connection.

        .PARAMETER Connection
        An explicit connection object, overriding the connected session.

        .EXAMPLE
        Get-ServiceNowJournalEntry -Sys_ID $incidentSysId

        Get all comments and work notes for an incident.

        .EXAMPLE
        Get-ServiceNowIncident -Number 'INC0010023' | Get-ServiceNowJournalEntry -Type work_notes

        Get just the work notes for an incident.

        .OUTPUTS
        Journal entry records (element, value, sys_created_on, sys_created_by).

        .LINK
        https://github.com/deanlongstaff/ServiceNow.API
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('SysId', 'Id')]
        [string]$Sys_ID,

        [Parameter()]
        [ValidateSet('comments', 'work_notes', 'all')]
        [string]$Type = 'all',

        [Parameter()]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$Limit,

        [Parameter()]
        [string]$Instance,

        [Parameter()]
        [hashtable]$Connection
    )

    process {
        $ConnectionParams = @{}
        if ($PSBoundParameters.ContainsKey('Connection')) { $ConnectionParams['Connection'] = $Connection }
        if ($PSBoundParameters.ContainsKey('Instance')) { $ConnectionParams['Instance'] = $Instance }

        $Encoded = "element_id=$Sys_ID"
        if ($Type -ne 'all') { $Encoded += "^element=$Type" }
        $Encoded += '^ORDERBYDESCsys_created_on'

        $QueryParams = @{
            sysparm_query  = $Encoded
            sysparm_fields = 'element,value,sys_created_on,sys_created_by'
        }
        if ($PSBoundParameters.ContainsKey('Limit')) { $QueryParams['sysparm_limit'] = $Limit }

        $Response = Invoke-ServiceNowApi -Method 'GET' -Path 'api/now/table/sys_journal_field' -Query $QueryParams @ConnectionParams
        return $Response.result
    }
}
