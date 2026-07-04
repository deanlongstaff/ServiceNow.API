function Invoke-ServiceNowGraphQL {
    <#
        .SYNOPSIS
        Runs a GraphQL query against ServiceNow.

        .DESCRIPTION
        Sends a query to the ServiceNow GraphQL API, which can return fields from several related
        tables in a single request. Supply the query text and, optionally, a hashtable of variables.
        The parsed 'data' portion of the response is returned; if the response contains GraphQL
        errors, a warning is written.

        .PARAMETER Query
        The GraphQL query text.

        .PARAMETER Variables
        A hashtable of variables referenced by the query.

        .PARAMETER Instance
        The name of a connected instance to target, instead of the default connection.

        .PARAMETER Connection
        An explicit connection object, overriding the connected session.

        .EXAMPLE
        $query = 'query { GlideRecord_Query { incident(queryConditions: "active=true", limit: 5) { _results { number { value } short_description { value } } } } }'
        Invoke-ServiceNowGraphQL -Query $query

        Retrieve fields from the incident table with GraphQL.

        .OUTPUTS
        The parsed 'data' object from the GraphQL response.

        .LINK
        https://github.com/deanlongstaff/ServiceNow.API
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$Query,

        [Parameter()]
        [hashtable]$Variables,

        [Parameter()]
        [string]$Instance,

        [Parameter()]
        [hashtable]$Connection
    )

    $ConnectionParams = @{}
    if ($PSBoundParameters.ContainsKey('Connection')) { $ConnectionParams['Connection'] = $Connection }
    if ($PSBoundParameters.ContainsKey('Instance')) { $ConnectionParams['Instance'] = $Instance }

    $Body = @{ query = $Query }
    if ($Variables) { $Body['variables'] = $Variables }

    $Response = Invoke-ServiceNowApi -Method 'POST' -Path 'api/now/graphql' -Body $Body @ConnectionParams

    # -- Member access works for both a real ConvertFrom-Json object and a hashtable.
    $GraphErrors = $Response.errors
    if ($GraphErrors) {
        $Messages = ($GraphErrors | ForEach-Object { $_.message }) -join '; '
        Write-Warning "GraphQL returned errors: $Messages"
    }

    $Data = $Response.data
    if ($null -ne $Data) {
        return $Data
    }
    return $Response
}
