function Get-ServiceNowChangeTask {
    <#
        .SYNOPSIS
        Retrieves change task records.

        .DESCRIPTION
        A convenience wrapper around Get-ServiceNowRecord for the 'change_task' table. It accepts all
        the same filtering, field selection, sorting, pagination and connection parameters, and adds
        -Number to look up a change task by its number.

        .PARAMETER Number
        Look up change tasks by number, for example 'CTASK0010023'.

        .EXAMPLE
        Get-ServiceNowChangeTask -Number 'CTASK0010023'

        Get a single change task by number.

        .EXAMPLE
        Get-ServiceNowChangeTask -Query 'change_request.number=CHG0030045'

        Get the change tasks for a specific change request.

        .OUTPUTS
        The matching change task record(s).

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

        Get-ServiceNowRecord -Table 'change_task' @Forward
    }
}
