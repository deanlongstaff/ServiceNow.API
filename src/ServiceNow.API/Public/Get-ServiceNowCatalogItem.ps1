function Get-ServiceNowCatalogItem {
    <#
        .SYNOPSIS
        Retrieves items from the ServiceNow Service Catalog.

        .DESCRIPTION
        Uses the Service Catalog API to list or search catalog items, or to get a single item (including
        its variables) by sys_id. Filter by a free-text search, a category, or a specific catalog.

        .PARAMETER Sys_ID
        The sys_id of a single catalog item to retrieve, including its variable definitions.

        .PARAMETER Query
        A free-text search across catalog items (sysparm_text).

        .PARAMETER Category
        Limit results to a catalog category sys_id.

        .PARAMETER CatalogId
        Limit results to a specific catalog sys_id.

        .PARAMETER Limit
        The maximum number of items to return.

        .PARAMETER Offset
        The starting offset (number of items to skip).

        .PARAMETER Instance
        The name of a connected instance to target, instead of the default connection.

        .PARAMETER Connection
        An explicit connection object, overriding the connected session.

        .EXAMPLE
        Get-ServiceNowCatalogItem -Query 'laptop'

        Search the catalog for items matching 'laptop'.

        .EXAMPLE
        Get-ServiceNowCatalogItem -Sys_ID $itemSysId

        Get a single catalog item and its variables.

        .OUTPUTS
        Catalog item object(s).

        .LINK
        https://github.com/deanlongstaff/ServiceNow.API
    #>
    [CmdletBinding(DefaultParameterSetName = 'List')]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'Single', Position = 0, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('SysId', 'Id')]
        [string]$Sys_ID,

        [Parameter(ParameterSetName = 'List')]
        [Alias('Text', 'Search')]
        [string]$Query,

        [Parameter(ParameterSetName = 'List')]
        [string]$Category,

        [Parameter(ParameterSetName = 'List')]
        [string]$CatalogId,

        [Parameter(ParameterSetName = 'List')]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$Limit,

        [Parameter(ParameterSetName = 'List')]
        [ValidateRange(0, [int]::MaxValue)]
        [int]$Offset = 0,

        [Parameter()]
        [string]$Instance,

        [Parameter()]
        [hashtable]$Connection
    )

    process {
        $ConnectionParams = @{}
        if ($PSBoundParameters.ContainsKey('Connection')) { $ConnectionParams['Connection'] = $Connection }
        if ($PSBoundParameters.ContainsKey('Instance')) { $ConnectionParams['Instance'] = $Instance }

        if ($PSCmdlet.ParameterSetName -eq 'Single') {
            $Response = Invoke-ServiceNowApi -Method 'GET' -Path "api/sn_sc/servicecatalog/items/$Sys_ID" @ConnectionParams
            return $Response.result
        }

        $QueryParams = @{}
        if ($Query) { $QueryParams['sysparm_text'] = $Query }
        if ($Category) { $QueryParams['sysparm_category'] = $Category }
        if ($CatalogId) { $QueryParams['sysparm_catalog'] = $CatalogId }
        if ($PSBoundParameters.ContainsKey('Limit')) { $QueryParams['sysparm_limit'] = $Limit }
        if ($Offset) { $QueryParams['sysparm_offset'] = $Offset }

        $Response = Invoke-ServiceNowApi -Method 'GET' -Path 'api/sn_sc/servicecatalog/items' -Query $QueryParams @ConnectionParams
        return $Response.result
    }
}
