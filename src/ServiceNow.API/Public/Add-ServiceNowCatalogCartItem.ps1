function Add-ServiceNowCatalogCartItem {
    <#
        .SYNOPSIS
        Adds a Service Catalog item to the cart.

        .DESCRIPTION
        Adds a catalog item to the current user's cart using the Service Catalog API. Supply the catalog
        item sys_id, an optional quantity, and any variable values the item requires. Build up a cart
        with several items, then place the order with Submit-ServiceNowCatalogCart.

        .PARAMETER Sys_ID
        The sys_id of the catalog item to add.

        .PARAMETER Quantity
        The quantity to add. Defaults to 1.

        .PARAMETER Variable
        A hashtable of the item's variable names and values.

        .PARAMETER Instance
        The name of a connected instance to target, instead of the default connection.

        .PARAMETER Connection
        An explicit connection object, overriding the connected session.

        .EXAMPLE
        Add-ServiceNowCatalogCartItem -Sys_ID $itemSysId -Quantity 2 -Variable @{ colour = 'black' }

        Add two of a catalog item to the cart with a variable value.

        .OUTPUTS
        The updated cart contents.

        .LINK
        https://github.com/deanlongstaff/ServiceNow.API
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('SysId', 'Id', 'ItemId')]
        [string]$Sys_ID,

        [Parameter()]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$Quantity = 1,

        [Parameter()]
        [hashtable]$Variable,

        [Parameter()]
        [string]$Instance,

        [Parameter()]
        [hashtable]$Connection
    )

    process {
        $ConnectionParams = @{}
        if ($PSBoundParameters.ContainsKey('Connection')) { $ConnectionParams['Connection'] = $Connection }
        if ($PSBoundParameters.ContainsKey('Instance')) { $ConnectionParams['Instance'] = $Instance }

        $Body = @{ sysparm_quantity = [string]$Quantity }
        if ($Variable) { $Body['variables'] = $Variable }

        if ($PSCmdlet.ShouldProcess($Sys_ID, "Add catalog item to cart (quantity $Quantity)")) {
            $Response = Invoke-ServiceNowApi -Method 'POST' -Path "api/sn_sc/servicecatalog/items/$Sys_ID/add_to_cart" -Body $Body @ConnectionParams
            return $Response.result
        }
    }
}
