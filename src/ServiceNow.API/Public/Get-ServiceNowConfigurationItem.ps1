function Get-ServiceNowConfigurationItem {
    <#
        .SYNOPSIS
        Retrieves configuration item (cmdb_ci) records.

        .DESCRIPTION
        A convenience wrapper around Get-ServiceNowRecord for the 'cmdb_ci' table (the CMDB base
        class). It accepts all the same filtering, field selection, sorting, pagination and connection
        parameters. Query a more specific CMDB class by using Get-ServiceNowRecord with that table name.

        .EXAMPLE
        Get-ServiceNowConfigurationItem -Query 'name=EXCHANGE01'

        Get a configuration item by name.

        .EXAMPLE
        Get-ServiceNowConfigurationItem -Filter @('operational_status', '-eq', '1') -Fields name, sys_class_name

        List operational configuration items with their class.

        .OUTPUTS
        The matching configuration item record(s).

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

        Get-ServiceNowRecord -Table 'cmdb_ci' @Forward
    }
}
