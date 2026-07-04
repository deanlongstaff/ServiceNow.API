function Get-ServiceNowKnowledgeArticle {
    <#
        .SYNOPSIS
        Retrieves Knowledge Base articles from ServiceNow.

        .DESCRIPTION
        Uses the Knowledge Management API to search for Knowledge Base articles by text, or to retrieve
        a single article by its number or sys_id (including the rendered article body). Only articles
        the connected user is permitted to view are returned.

        .PARAMETER ArticleId
        The article number (for example 'KB0010001') or sys_id of a single article to retrieve.

        .PARAMETER Query
        A free-text search across knowledge articles.

        .PARAMETER KnowledgeBase
        Limit the search to one or more knowledge base sys_ids.

        .PARAMETER Language
        The language code for the results, for example 'en'.

        .PARAMETER Limit
        The maximum number of articles to return.

        .PARAMETER Offset
        The starting offset (number of articles to skip).

        .PARAMETER Instance
        The name of a connected instance to target, instead of the default connection.

        .PARAMETER Connection
        An explicit connection object, overriding the connected session.

        .EXAMPLE
        Get-ServiceNowKnowledgeArticle -Query 'vpn setup'

        Search the knowledge base for VPN setup articles.

        .EXAMPLE
        Get-ServiceNowKnowledgeArticle -ArticleId 'KB0010001'

        Retrieve a single article and its content.

        .OUTPUTS
        Knowledge article object(s).

        .LINK
        https://github.com/deanlongstaff/ServiceNow.API
    #>
    [CmdletBinding(DefaultParameterSetName = 'Search')]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'Single', Position = 0, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('SysId', 'Id', 'Number')]
        [string]$ArticleId,

        [Parameter(ParameterSetName = 'Search', Position = 0)]
        [Alias('Text', 'Search')]
        [string]$Query,

        [Parameter(ParameterSetName = 'Search')]
        [string[]]$KnowledgeBase,

        [Parameter(ParameterSetName = 'Search')]
        [string]$Language,

        [Parameter(ParameterSetName = 'Search')]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$Limit,

        [Parameter(ParameterSetName = 'Search')]
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
            $Response = Invoke-ServiceNowApi -Method 'GET' -Path "api/sn_km_api/knowledge/articles/$ArticleId" @ConnectionParams
            return $Response.result
        }

        $QueryParams = @{}
        if ($Query) { $QueryParams['query'] = $Query }
        if ($KnowledgeBase) { $QueryParams['kb'] = ($KnowledgeBase -join ',') }
        if ($Language) { $QueryParams['language'] = $Language }
        if ($PSBoundParameters.ContainsKey('Limit')) { $QueryParams['limit'] = $Limit }
        if ($Offset) { $QueryParams['offset'] = $Offset }

        $Response = Invoke-ServiceNowApi -Method 'GET' -Path 'api/sn_km_api/knowledge/articles' -Query $QueryParams @ConnectionParams

        # -- The search endpoint nests results under result.articles; return that when present.
        $Result = $Response.result
        if ($null -ne $Result -and $null -ne $Result.articles) {
            return $Result.articles
        }
        return $Result
    }
}
