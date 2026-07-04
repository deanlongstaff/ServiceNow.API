function Get-ServiceNowCmdbInstance {
    <#
        .SYNOPSIS
        Retrieves configuration items through the CMDB Instance API.

        .DESCRIPTION
        Uses the class-aware CMDB Instance API rather than the raw Table API. With -Sys_ID it returns a
        single configuration item including its attributes and its inbound and outbound relationships;
        otherwise it lists items of the given class, optionally filtered by a query. This respects the
        CMDB class model, so it is the recommended way to read CMDB data.

        .PARAMETER Class
        The CMDB class (table) to query, for example 'cmdb_ci_linux_server'.

        .PARAMETER Sys_ID
        The sys_id of a single configuration item to retrieve, with its relationships.

        .PARAMETER Query
        A raw encoded query to filter the listed items.

        .PARAMETER Filter
        A structured filter turned into an encoded query by New-ServiceNowQuery.

        .PARAMETER Limit
        The maximum number of items to return when listing.

        .PARAMETER Offset
        The starting offset (number of items to skip) when listing.

        .PARAMETER Instance
        The name of a connected instance to target, instead of the default connection.

        .PARAMETER Connection
        An explicit connection object, overriding the connected session.

        .EXAMPLE
        Get-ServiceNowCmdbInstance -Class cmdb_ci_linux_server -Sys_ID $sysId

        Get a single Linux server CI with its relationships.

        .EXAMPLE
        Get-ServiceNowCmdbInstance -Class cmdb_ci_service -Query 'operational_status=1' -Limit 50

        List operational business services.

        .OUTPUTS
        The configuration item(s), including relationships for a single item.

        .LINK
        https://github.com/deanlongstaff/ServiceNow.API
    #>
    [CmdletBinding(DefaultParameterSetName = 'List')]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [Alias('sys_class_name')]
        [string]$Class,

        [Parameter(Mandatory = $true, ParameterSetName = 'Single', ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('SysId', 'Id')]
        [string]$Sys_ID,

        [Parameter(ParameterSetName = 'List')]
        [Alias('FilterString')]
        [string]$Query,

        [Parameter(ParameterSetName = 'List')]
        [object[]]$Filter,

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
            $Response = Invoke-ServiceNowApi -Method 'GET' -Path "api/now/cmdb/instance/$Class/$Sys_ID" @ConnectionParams
            return $Response.result
        }

        $QueryParams = @{}
        $Encoded = if ($Filter) { New-ServiceNowQuery -Filter $Filter } else { [string]$Query }
        if (-not [string]::IsNullOrEmpty($Encoded)) { $QueryParams['sysparm_query'] = $Encoded }
        if ($PSBoundParameters.ContainsKey('Limit')) { $QueryParams['sysparm_limit'] = $Limit }
        if ($Offset) { $QueryParams['sysparm_offset'] = $Offset }

        $Response = Invoke-ServiceNowApi -Method 'GET' -Path "api/now/cmdb/instance/$Class" -Query $QueryParams @ConnectionParams
        return $Response.result
    }
}
