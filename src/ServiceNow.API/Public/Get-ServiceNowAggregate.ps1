function Get-ServiceNowAggregate {
    <#
        .SYNOPSIS
        Runs an aggregate query against a ServiceNow table.

        .DESCRIPTION
        Uses the Aggregate API to compute counts and statistics server-side, without returning the
        underlying records. Count matching rows, average, sum, or find the minimum and maximum of
        numeric fields, and group the results by one or more fields. This is far more efficient than
        retrieving records and aggregating in PowerShell.

        .PARAMETER Table
        The table to aggregate, for example 'incident'.

        .PARAMETER Query
        A raw encoded query to filter the rows before aggregating.

        .PARAMETER Filter
        A structured filter turned into an encoded query by New-ServiceNowQuery.

        .PARAMETER Count
        Return the count of matching rows.

        .PARAMETER GroupBy
        One or more fields to group the results by.

        .PARAMETER Average
        Fields to average.

        .PARAMETER Sum
        Fields to sum.

        .PARAMETER Minimumto several instances at once, then target any of them
  per call with `-Instance <name>` (or an explicit `-Connection` object). With neither, the most
  recently connected instance is used

        .PARAMETER Maximum
        Fields to take the maximum of.

        .PARAMETER Having
        An aggregate filter, for example 'count>3'.

        .PARAMETER OrderBy
        An aggregate ordering, for example 'count' or 'AVG^priority^DESC'.

        .PARAMETER DisplayValue
        Return display values, underlying values, or both: 'true', 'false' or 'all'.

        .PARAMETER Instance
        The name of a connected instance to target, instead of the default connection.

        .PARAMETER Connection
        An explicit connection object, overriding the connected session.

        .EXAMPLE
        Get-ServiceNowAggregate -Table incident -Count -Filter @('active', '-eq', 'true')

        Count active incidents.

        .EXAMPLE
        Get-ServiceNowAggregate -Table incident -Count -GroupBy priority

        Count incidents grouped by priority.

        .OUTPUTS
        The aggregate result object(s).

        .LINK
        https://github.com/deanlongstaff/ServiceNow.API
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$Table,

        [Parameter()]
        [Alias('FilterString')]
        [string]$Query,

        [Parameter()]
        [object[]]$Filter,

        [Parameter()]
        [switch]$Count,

        [Parameter()]
        [string[]]$GroupBy,

        [Parameter()]
        [string[]]$Average,

        [Parameter()]
        [string[]]$Sum,

        [Parameter()]
        [string[]]$Minimum,

        [Parameter()]
        [string[]]$Maximum,

        [Parameter()]
        [string]$Having,

        [Parameter()]
        [string]$OrderBy,

        [Parameter()]
        [ValidateSet('true', 'false', 'all')]
        [string]$DisplayValue,

        [Parameter()]
        [string]$Instance,

        [Parameter()]
        [hashtable]$Connection
    )

    $ConnectionParams = @{}
    if ($PSBoundParameters.ContainsKey('Connection')) { $ConnectionParams['Connection'] = $Connection }
    if ($PSBoundParameters.ContainsKey('Instance')) { $ConnectionParams['Instance'] = $Instance }

    $QueryParams = @{}
    if ($Count) { $QueryParams['sysparm_count'] = 'true' }
    if ($Average) { $QueryParams['sysparm_avg_fields'] = ($Average -join ',') }
    if ($Sum) { $QueryParams['sysparm_sum_fields'] = ($Sum -join ',') }
    if ($Minimum) { $QueryParams['sysparm_min_fields'] = ($Minimum -join ',') }
    if ($Maximum) { $QueryParams['sysparm_max_fields'] = ($Maximum -join ',') }
    if ($GroupBy) { $QueryParams['sysparm_group_by'] = ($GroupBy -join ',') }
    if ($Having) { $QueryParams['sysparm_having'] = $Having }
    if ($OrderBy) { $QueryParams['sysparm_orderby'] = $OrderBy }
    if ($DisplayValue) { $QueryParams['sysparm_display_value'] = $DisplayValue }

    $Encoded = if ($Filter) { New-ServiceNowQuery -Filter $Filter } else { [string]$Query }
    if (-not [string]::IsNullOrEmpty($Encoded)) { $QueryParams['sysparm_query'] = $Encoded }

    $Response = Invoke-ServiceNowApi -Method 'GET' -Path "api/now/stats/$Table" -Query $QueryParams @ConnectionParams
    return $Response.result
}
