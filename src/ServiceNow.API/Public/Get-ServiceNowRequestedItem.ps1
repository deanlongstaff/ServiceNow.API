function Get-ServiceNowRequestedItem {
    <#
        .SYNOPSIS
        Retrieves requested item (RITM) records.

        .DESCRIPTION
        A convenience wrapper around Get-ServiceNowRecord for the 'sc_req_item' table. It accepts all
        the same filtering, field selection, sorting, pagination and connection parameters, and adds
        -Number to look up a requested item by its number.

        .PARAMETER Number
        Look up requested items by number, for example 'RITM0010001'.

        .EXAMPLE
        Get-ServiceNowRequestedItem -Number 'RITM0010001'

        Get a single requested item by number.

        .EXAMPLE
        Get-ServiceNowRequestedItem -Query 'request.number=REQ0010001'

        Get the requested items that belong to a request.

        .OUTPUTS
        The matching requested item record(s).

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

        Get-ServiceNowRecord -Table 'sc_req_item' @Forward
    }
}
