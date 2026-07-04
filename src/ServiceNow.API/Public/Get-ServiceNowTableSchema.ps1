function Get-ServiceNowTableSchema {
    <#
        .SYNOPSIS
        Describes the columns of a ServiceNow table.

        .DESCRIPTION
        Returns the field (column) definitions for a table by reading the sys_dictionary table. This is
        useful for discovering the columns defined on a table, their labels, types, whether they are
        mandatory or read-only, and which table a reference field points to.

        Only the columns defined directly on the specified table are returned. To see fields a table
        inherits, describe its parent table as well (for example, 'incident' extends 'task').

        .PARAMETER Table
        The table to describe, for example 'incident'.

        .PARAMETER Instance
        The name of a connected instance to target, instead of the default connection.

        .PARAMETER Connection
        An explicit connection object, overriding the connected session.

        .EXAMPLE
        Get-ServiceNowTableSchema -Table incident

        List the columns on the incident table.

        .EXAMPLE
        Get-ServiceNowTableSchema -Table incident | Where-Object Mandatory -eq 'true'

        Find the mandatory fields on the incident table.

        .OUTPUTS
        Column definition objects (Element, Label, Type, Reference, Mandatory, MaxLength, Active).

        .LINK
        https://github.com/deanlongstaff/ServiceNow.API
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('sys_class_name')]
        [string]$Table,

        [Parameter()]
        [string]$Instance,

        [Parameter()]
        [hashtable]$Connection
    )

    process {
        $ConnectionParams = @{}
        if ($PSBoundParameters.ContainsKey('Connection')) { $ConnectionParams['Connection'] = $Connection }
        if ($PSBoundParameters.ContainsKey('Instance')) { $ConnectionParams['Instance'] = $Instance }

        # -- Real columns only (element not empty). display_value=all lets us show the readable field
        #    type name while still returning the reference table's raw name.
        $QueryParams = @{
            sysparm_query         = "name=$Table^elementISNOTEMPTY^ORDERBYelement"
            sysparm_fields        = 'element,column_label,internal_type,reference,mandatory,max_length,default_value,active,read_only'
            sysparm_display_value = 'all'
            sysparm_limit         = 10000
        }

        $Response = Invoke-ServiceNowApi -Method 'GET' -Path 'api/now/table/sys_dictionary' -Query $QueryParams @ConnectionParams

        foreach ($Column in @($Response.result)) {
            [pscustomobject]@{
                PSTypeName = 'ServiceNow.API.Column'
                Element    = $Column.element.value
                Label      = $Column.column_label.display_value
                Type       = $Column.internal_type.display_value
                Reference  = $Column.reference.value
                Mandatory  = $Column.mandatory.value
                ReadOnly   = $Column.read_only.value
                MaxLength  = $Column.max_length.value
                Default    = $Column.default_value.value
                Active     = $Column.active.value
            }
        }
    }
}
