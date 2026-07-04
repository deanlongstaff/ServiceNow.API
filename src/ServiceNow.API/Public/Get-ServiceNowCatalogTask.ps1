function Get-ServiceNowCatalogTask {
    <#
        .SYNOPSIS
        Retrieves catalog task (SCTASK) records.

        .DESCRIPTION
        A convenience wrapper around Get-ServiceNowRecord for the 'sc_task' table. It accepts all the
        same filtering, field selection, sorting, pagination and connection parameters, and adds
        -Number to look up a catalog task by its number.

        .PARAMETER Number
        Look up catalog tasks by number, for example 'SCTASK0010001'.

        .EXAMPLE
        Get-ServiceNowCatalogTask -Number 'SCTASK0010001'

        Get a single catalog task by number.

        .EXAMPLE
        Get-ServiceNowCatalogTask -Query 'request_item.number=RITM0010001'

        Get the catalog tasks for a requested item.

        .OUTPUTS
        The matching catalog task record(s).

        .LINK
        https://github.com/deanlongstaff/ServiceNow.API
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter()]
        [string]$Number
    )

    DynamicParam { Import-ServiceNowTemplateParameter -TemplateFunction 'Get-ServiceNowRecord' -Exclude 'Table' }

    process {
        $Forward = @{}
        foreach ($Key in $PSBoundParameters.Keys) {
            if ($Key -eq 'Number') { continue }
            $Forward[$Key] = $PSBoundParameters[$Key]
        }

        if ($PSBoundParameters.ContainsKey('Number')) {
            if ($Forward.ContainsKey('Filter')) {
                throw "Use either -Number or -Filter, not both. Add @('number', '-eq', '$Number') to your -Filter instead."
            }
            $NumberQuery = "number=$Number"
            if ($Forward.ContainsKey('Query') -and $Forward['Query']) {
                $Forward['Query'] = "$($Forward['Query'])^$NumberQuery"
            }
            else {
                $Forward['Query'] = $NumberQuery
            }
        }

        Get-ServiceNowRecord -Table 'sc_task' @Forward
    }
}
