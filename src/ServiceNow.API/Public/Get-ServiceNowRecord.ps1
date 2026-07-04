function Get-ServiceNowRecord {
    <#
        .SYNOPSIS
        Retrieves records from any ServiceNow table.

        .DESCRIPTION
        Queries the ServiceNow Table API and returns matching records. Retrieve a single record by
        sys_id, or filter a table using either a structured -Filter (see New-ServiceNowQuery), a raw
        encoded -Query copied from the ServiceNow list view, or both. Results are paginated
        automatically; use -Limit to cap the number of records returned.

        .PARAMETER Table
        The table to query, by name (for example 'incident', 'sys_user', 'cmdb_ci').

        .PARAMETER Sys_ID
        Retrieve a single record directly by its sys_id.

        .PARAMETER Query
        A raw encoded query string, as copied from the ServiceNow list view ('Copy query'), for example
        'active=true^priority=1'.

        .PARAMETER Filter
        A structured filter turned into an encoded query by New-ServiceNowQuery. Conditions are arrays
        of @(field, operator, value) combined with 'and', 'or' and 'group'.

        .PARAMETER Sort
        One or more sort pairs, each @(field, 'asc'|'desc').

        .PARAMETER Fields
        The fields to return. Fewer fields means smaller, faster responses.

        .PARAMETER DisplayValue
        Return the display value, the underlying value, or both: 'true', 'false' or 'all'.

        .PARAMETER ExcludeReferenceLinks
        Remove the link objects from reference fields, returning just the value.

        .PARAMETER Offset
        The starting offset (number of records to skip).

        .PARAMETER Limit
        The maximum number of records to return across all pages.

        .PARAMETER RestrictDomain
        Restrict results to the caller's domains (sends sysparm_query_no_domain=false). Requires the
        appropriate role on the instance.

        .PARAMETER SysParmView
        The UI view whose fields should be returned: 'desktop', 'mobile' or 'both'.

        .PARAMETER Instance
        The name of a connected instance to target, instead of the default connection.

        .PARAMETER Connection
        An explicit connection object, overriding the connected session.

        .EXAMPLE
        Get-ServiceNowRecord -Table incident -Sys_ID '46b66a40a9fe198101f243dfbc79033d'

        Get a single incident by sys_id.

        .EXAMPLE
        Get-ServiceNowRecord -Table incident -Filter @('active', '-eq', 'true'), 'and', @('priority', '-le', '2') -Sort @('opened_at', 'desc') -Fields number, short_description

        Get active priority 1-2 incidents, newest first, returning two fields.

        .EXAMPLE
        Get-ServiceNowRecord -Table sys_user -Query 'active=true' -Limit 100

        Get the first 100 active users using a raw encoded query.

        .OUTPUTS
        The matching record objects.

        .LINK
        https://github.com/deanlongstaff/ServiceNow.API
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    [Alias('gsnr')]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('sys_class_name')]
        [string]$Table,

        [Parameter(Position = 1, ValueFromPipelineByPropertyName = $true)]
        [Alias('SysId', 'Id')]
        [string]$Sys_ID,

        [Parameter()]
        [Alias('FilterString')]
        [string]$Query,

        [Parameter()]
        [object[]]$Filter,

        [Parameter()]
        [object[]]$Sort,

        [Parameter()]
        [Alias('Property', 'Properties')]
        [string[]]$Fields,

        [Parameter()]
        [ValidateSet('true', 'false', 'all')]
        [string]$DisplayValue,

        [Parameter()]
        [switch]$ExcludeReferenceLinks,

        [Parameter()]
        [ValidateRange(0, [int]::MaxValue)]
        [int]$Offset = 0,

        [Parameter()]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$Limit,

        [Parameter()]
        [switch]$RestrictDomain,

        [Parameter()]
        [ValidateSet('desktop', 'mobile', 'both')]
        [string]$SysParmView,

        [Parameter()]
        [string]$Instance,

        [Parameter()]
        [hashtable]$Connection
    )

    process {
        $ConnectionParams = @{}
        if ($PSBoundParameters.ContainsKey('Connection')) { $ConnectionParams['Connection'] = $Connection }
        if ($PSBoundParameters.ContainsKey('Instance')) { $ConnectionParams['Instance'] = $Instance }

        # -- Shared query-string parameters for both single and list lookups.
        $CommonQuery = @{}
        if ($Fields) { $CommonQuery['sysparm_fields'] = ($Fields -join ',') }
        if ($DisplayValue) { $CommonQuery['sysparm_display_value'] = $DisplayValue }
        if ($ExcludeReferenceLinks) { $CommonQuery['sysparm_exclude_reference_link'] = 'true' }
        if ($RestrictDomain) { $CommonQuery['sysparm_query_no_domain'] = 'false' }
        if ($SysParmView) { $CommonQuery['sysparm_view'] = $SysParmView }

        # -- Single record lookup by sys_id.
        if ($PSBoundParameters.ContainsKey('Sys_ID') -and -not [string]::IsNullOrWhiteSpace($Sys_ID)) {
            try {
                $Response = Invoke-ServiceNowApi -Method 'GET' -Path "api/now/table/$Table/$Sys_ID" -Query $CommonQuery @ConnectionParams
                return $Response.result
            }
            catch {
                if ($_.Exception.Data['ServiceNowStatusCode'] -eq 404) {
                    Write-Verbose "No $Table record found with sys_id '$Sys_ID'."
                    return
                }
                throw
            }
        }

        # -- Build the encoded query from -Filter/-Query and -Sort.
        $Encoded = $null
        if ($Filter) {
            $Encoded = New-ServiceNowQuery -Filter $Filter -Sort $Sort
        }
        elseif ($Query -or $Sort) {
            $Encoded = [string]$Query
            if ($Sort) { $Encoded += (New-ServiceNowQuery -Sort $Sort) }
            $Encoded = $Encoded.TrimStart('^')
        }
        if (-not [string]::IsNullOrEmpty($Encoded)) {
            $CommonQuery['sysparm_query'] = $Encoded
        }

        # -- Paginate. Default page size is 1000; a smaller -Limit reduces the page size.
        $PageSize = 1000
        if ($PSBoundParameters.ContainsKey('Limit') -and $Limit -lt $PageSize) {
            $PageSize = $Limit
        }
        $CurrentOffset = $Offset
        $Returned = 0

        while ($true) {
            $PageQuery = @{} + $CommonQuery
            $PageQuery['sysparm_limit'] = $PageSize
            $PageQuery['sysparm_offset'] = $CurrentOffset

            $Response = Invoke-ServiceNowApi -Method 'GET' -Path "api/now/table/$Table" -Query $PageQuery @ConnectionParams
            $Page = @($Response.result)
            if ($Page.Count -eq 0) { break }

            foreach ($Record in $Page) {
                $Record
                $Returned++
                if ($PSBoundParameters.ContainsKey('Limit') -and $Returned -ge $Limit) { return }
            }

            if ($Page.Count -lt $PageSize) { break }
            $CurrentOffset += $PageSize
        }
    }
}
