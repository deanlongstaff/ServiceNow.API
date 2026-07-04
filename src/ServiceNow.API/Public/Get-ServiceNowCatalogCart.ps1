function Get-ServiceNowCatalogCart {
    <#
        .SYNOPSIS
        Returns the current user's Service Catalog cart.

        .DESCRIPTION
        Retrieves the contents of the current user's cart using the Service Catalog API, including the
        items added and their variable values.

        .PARAMETER Instance
        The name of a connected instance to target, instead of the default connection.

        .PARAMETER Connection
        An explicit connection object, overriding the connected session.

        .EXAMPLE
        Get-ServiceNowCatalogCart

        Show the current cart contents.

        .OUTPUTS
        The cart contents object.

        .LINK
        https://github.com/deanlongstaff/ServiceNow.API
    #>
    [CmdletBinding()]
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

    $Response = Invoke-ServiceNowApi -Method 'GET' -Path 'api/sn_sc/servicecatalog/cart' @ConnectionParams
    return $Response.result
}
