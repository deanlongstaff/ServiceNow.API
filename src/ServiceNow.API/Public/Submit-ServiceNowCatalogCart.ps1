function Submit-ServiceNowCatalogCart {
    <#
        .SYNOPSIS
        Submits the current Service Catalog cart as an order.

        .DESCRIPTION
        Places an order for everything in the current user's cart using the Service Catalog API's
        submit_order endpoint. Returns the resulting request details, including the request number.
        Build the cart first with Add-ServiceNowCatalogCartItem.

        .PARAMETER Instance
        The name of a connected instance to target, instead of the default connection.

        .PARAMETER Connection
        An explicit connection object, overriding the connected session.

        .EXAMPLE
        Submit-ServiceNowCatalogCart

        Order everything currently in the cart.

        .OUTPUTS
        The order result, including the request number.

        .LINK
        https://github.com/deanlongstaff/ServiceNow.API
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([pscustomobject])]
    param(
        [Parameter()]
        [string]$Instance,

        [Parameter()]
        [hashtable]$Connection
    )

    $ConnectionParams = @{}
    if ($PSBoundParameters.ContainsKey('Connection')) { $ConnectionParams['Connection'] = $Connection }
    if ($PSBoundParameters.ContainsKey('Instance')) { $ConnectionParams['Instance'] = $Instance }

    if ($PSCmdlet.ShouldProcess('Service Catalog cart', 'Submit order')) {
        $Response = Invoke-ServiceNowApi -Method 'POST' -Path 'api/sn_sc/servicecatalog/cart/submit_order' @ConnectionParams
        return $Response.result
    }
}
