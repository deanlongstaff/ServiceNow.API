function Invoke-ServiceNowRestMethod {
    <#
        .SYNOPSIS
        Sends an arbitrary authenticated request to the ServiceNow REST API.

        .DESCRIPTION
        A general-purpose escape hatch for any ServiceNow REST endpoint not covered by a dedicated
        cmdlet. It reuses the module's authentication, token refresh, rate-limit handling and
        transient-error retries, so you only supply the method, path and body.

        .PARAMETER Method
        The HTTP method. Defaults to GET.

        .PARAMETER Path
        The endpoint path relative to the instance base URL (for example 'api/now/table/incident'), or
        an absolute instance URL.

        .PARAMETER Query
        Optional hashtable of query-string parameters, URL-encoded automatically.

        .PARAMETER Body
        Optional request body. A string is sent verbatim; any other object is serialised to JSON.

        .PARAMETER ContentType
        The request content type. Defaults to 'application/json'.

        .PARAMETER Headers
        Optional additional request headers.

        .PARAMETER Raw
        Return the raw response bytes instead of parsed JSON.

        .PARAMETER OutFile
        Write the response body to this path instead of returning it.

        .PARAMETER Instance
        The name of a connected instance to target, instead of the default connection.

        .PARAMETER Connection
        An explicit connection object, overriding the connected session.

        .EXAMPLE
        Invoke-ServiceNowRestMethod -Path 'api/now/table/incident' -Query @{ sysparm_limit = 1 }

        Call the Table API directly.

        .EXAMPLE
        Invoke-ServiceNowRestMethod -Method POST -Path 'api/sn_sc/servicecatalog/cart/checkout'

        Post to an endpoint with no dedicated cmdlet.

        .OUTPUTS
        The parsed response, raw bytes with -Raw, or nothing with -OutFile.

        .LINK
        https://github.com/deanlongstaff/ServiceNow.API
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter()]
        [ValidateSet('GET', 'POST', 'PATCH', 'PUT', 'DELETE')]
        [string]$Method = 'GET',

        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [Alias('Uri', 'UriLeaf')]
        [string]$Path,

        [Parameter()]
        [hashtable]$Query,

        [Parameter()]
        [object]$Body,

        [Parameter()]
        [string]$ContentType = 'application/json',

        [Parameter()]
        [hashtable]$Headers,

        [Parameter()]
        [switch]$Raw,

        [Parameter()]
        [string]$OutFile,

        [Parameter()]
        [string]$Instance,

        [Parameter()]
        [hashtable]$Connection
    )

    $ApiParams = @{
        Method      = $Method
        Path        = $Path
        ContentType = $ContentType
    }
    if ($PSBoundParameters.ContainsKey('Query')) { $ApiParams['Query'] = $Query }
    if ($PSBoundParameters.ContainsKey('Body')) { $ApiParams['Body'] = $Body }
    if ($PSBoundParameters.ContainsKey('Headers')) { $ApiParams['Headers'] = $Headers }
    if ($Raw) { $ApiParams['Raw'] = $true }
    if ($OutFile) { $ApiParams['OutFile'] = $OutFile }
    if ($PSBoundParameters.ContainsKey('Connection')) { $ApiParams['Connection'] = $Connection }
    if ($PSBoundParameters.ContainsKey('Instance')) { $ApiParams['Instance'] = $Instance }

    if ($Method -eq 'GET' -or $PSCmdlet.ShouldProcess($Path, "ServiceNow $Method")) {
        return Invoke-ServiceNowApi @ApiParams
    }
}
