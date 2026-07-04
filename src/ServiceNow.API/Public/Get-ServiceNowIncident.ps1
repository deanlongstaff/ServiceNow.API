function Get-ServiceNowIncident {
    <#
        .SYNOPSIS
        Retrieves incident records.

        .DESCRIPTION
        A convenience wrapper around Get-ServiceNowRecord for the 'incident' table, so you do not have
        to remember the table name. It accepts all the same filtering, field selection, sorting,
        pagination and connection parameters as Get-ServiceNowRecord, and adds -Number to look up an
        incident by its number.

        .PARAMETER Number
        Look up incidents by number, for example 'INC0010023'.

        .EXAMPLE
        Get-ServiceNowIncident -Number 'INC0010023'

        Get a single incident by number.

        .EXAMPLE
        Get-ServiceNowIncident -Filter @('active', '-eq', 'true') -Sort @('opened_at', 'desc') -Limit 10

        Get the ten most recent active incidents.

        .OUTPUTS
        The matching incident record(s).

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

        Get-ServiceNowRecord -Table 'incident' @Forward
    }
}
