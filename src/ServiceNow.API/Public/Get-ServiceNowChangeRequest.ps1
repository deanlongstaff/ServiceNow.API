function Get-ServiceNowChangeRequest {
    <#
        .SYNOPSIS
        Retrieves change request records.

        .DESCRIPTION
        A convenience wrapper around Get-ServiceNowRecord for the 'change_request' table. It accepts
        all the same filtering, field selection, sorting, pagination and connection parameters, and
        adds -Number to look up a change request by its number.

        .PARAMETER Number
        Look up change requests by number, for example 'CHG0030045'.

        .EXAMPLE
        Get-ServiceNowChangeRequest -Number 'CHG0030045'

        Get a single change request by number.

        .EXAMPLE
        Get-ServiceNowChangeRequest -Filter @('state', '-eq', '-5') -Limit 20

        Get change requests in the 'New' state.

        .OUTPUTS
        The matching change request record(s).

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

        Get-ServiceNowRecord -Table 'change_request' @Forward
    }
}
