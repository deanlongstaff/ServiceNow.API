function Get-ServiceNowRequest {
    <#
        .SYNOPSIS
        Retrieves service catalog request (REQ) records.

        .DESCRIPTION
        A convenience wrapper around Get-ServiceNowRecord for the 'sc_request' table. It accepts all
        the same filtering, field selection, sorting, pagination and connection parameters, and adds
        -Number to look up a request by its number.

        .PARAMETER Number
        Look up requests by number, for example 'REQ0010001'.

        .EXAMPLE
        Get-ServiceNowRequest -Number 'REQ0010001'

        Get a single request by number.

        .OUTPUTS
        The matching request record(s).

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

        Get-ServiceNowRecord -Table 'sc_request' @Forward
    }
}
