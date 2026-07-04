function Get-ServiceNowGroup {
    <#
        .SYNOPSIS
        Retrieves group (sys_user_group) records.

        .DESCRIPTION
        A convenience wrapper around Get-ServiceNowRecord for the 'sys_user_group' table. It accepts
        all the same filtering, field selection, sorting, pagination and connection parameters. Look
        groups up by any field with -Query or -Filter (for example name or type).

        .EXAMPLE
        Get-ServiceNowGroup -Query 'name=Service Desk'

        Get a group by name.

        .EXAMPLE
        Get-ServiceNowGroup -Filter @('active', '-eq', 'true') -Fields name, description

        List active groups with a couple of fields.

        .OUTPUTS
        The matching group record(s).

        .LINK
        https://github.com/deanlongstaff/ServiceNow.API
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param()

    DynamicParam { Import-ServiceNowTemplateParameter -TemplateFunction 'Get-ServiceNowRecord' -Exclude 'Table' }

    process {
        $Forward = @{}
        foreach ($Key in $PSBoundParameters.Keys) {
            $Forward[$Key] = $PSBoundParameters[$Key]
        }

        Get-ServiceNowRecord -Table 'sys_user_group' @Forward
    }
}
