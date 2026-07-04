function Get-ServiceNowProblem {
    <#
        .SYNOPSIS
        Retrieves problem records.

        .DESCRIPTION
        A convenience wrapper around Get-ServiceNowRecord for the 'problem' table. It accepts all the
        same filtering, field selection, sorting, pagination and connection parameters, and adds
        -Number to look up a problem by its number.

        .PARAMETER Number
        Look up problems by number, for example 'PRB0040001'.

        .EXAMPLE
        Get-ServiceNowProblem -Number 'PRB0040001'

        Get a single problem by number.

        .EXAMPLE
        Get-ServiceNowProblem -Filter @('active', '-eq', 'true') -Sort @('opened_at', 'desc')

        Get active problems, newest first.

        .OUTPUTS
        The matching problem record(s).

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

        Get-ServiceNowRecord -Table 'problem' @Forward
    }
}
