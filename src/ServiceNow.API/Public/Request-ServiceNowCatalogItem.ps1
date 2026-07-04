function Request-ServiceNowCatalogItem {
    <#
        .SYNOPSIS
        Orders a Service Catalog item directly.

        .DESCRIPTION
        Places an immediate order for a single catalog item using the Service Catalog API's order_now
        endpoint, bypassing the cart. Supply the catalog item sys_id, an optional quantity, and any
        variable values the item requires. Returns the resulting request details, including the request
        number.

        .PARAMETER Sys_ID
        The sys_id of the catalog item to order.

        .PARAMETER Quantity
        The quantity to order. Defaults to 1.

        .PARAMETER Variable
        A hashtable of the item's variable names and values.

        .PARAMETER Instance
        The name of a connected instance to target, instead of the default connection.

        .PARAMETER Connection
        An explicit connection object, overriding the connected session.

        .EXAMPLE
        Request-ServiceNowCatalogItem -Sys_ID $itemSysId -Variable @{ requested_for = $userSysId; comments = 'Please expedite' }

        Order a catalog item with variable values.

        .OUTPUTS
        The order result, including the request number.

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

        if ($PSCmdlet.ShouldProcess($Sys_ID, "Order catalog item (quantity $Quantity)")) {
            $Response = Invoke-ServiceNowApi -Method 'POST' -Path "api/sn_sc/servicecatalog/items/$Sys_ID/order_now" -Body $Body @ConnectionParams
            return $Response.result
        }
    }
}
