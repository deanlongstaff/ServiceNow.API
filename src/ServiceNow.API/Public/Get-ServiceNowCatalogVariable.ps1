function Get-ServiceNowCatalogVariable {
    <#
        .SYNOPSIS
        Retrieves the catalog variable values submitted on a requested item.

        .DESCRIPTION
        Returns the variables (the answers a user gave on the catalog form) for a requested item
        (RITM). It reads the sc_item_option_mtom join and dot-walks to each variable's name, question
        and value, returning a clean object per variable. Requested item objects from
        Get-ServiceNowRequestedItem can be piped straight in.

        .PARAMETER RequestedItemId
        The sys_id of the requested item (RITM) whose variables you want.

        .PARAMETER Instance
        The name of a connected instance to target, instead of the default connection.

        .PARAMETER Connection
        An explicit connection object, overriding the connected session.

        .EXAMPLE
        Get-ServiceNowCatalogVariable -RequestedItemId $ritmSysId

        Get the variable values for a requested item.

        .EXAMPLE
        Get-ServiceNowRequestedItem -Number 'RITM0010001' | Get-ServiceNowCatalogVariable

        Get the variables for a RITM by piping it in.

        .OUTPUTS
        One object per variable, with Name, Question and Value.

        .LINK
        https://github.com/deanlongstaff/ServiceNow.API
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('SysId', 'Id', 'request_item')]
        [string]$RequestedItemId,

        [Parameter()]
        [string]$Instance,

        [Parameter()]
        [hashtable]$Connection
    )

    process {
        $ConnectionParams = @{}
        if ($PSBoundParameters.ContainsKey('Connection')) { $ConnectionParams['Connection'] = $Connection }
        if ($PSBoundParameters.ContainsKey('Instance')) { $ConnectionParams['Instance'] = $Instance }

        $QueryParams = @{
            sysparm_query                  = "request_item=$RequestedItemId"
            sysparm_fields                 = 'sc_item_option.item_option_new.name,sc_item_option.item_option_new.question_text,sc_item_option.value'
            sysparm_display_value          = 'false'
            sysparm_exclude_reference_link = 'true'
        }

        $Response = Invoke-ServiceNowApi -Method 'GET' -Path 'api/now/table/sc_item_option_mtom' -Query $QueryParams @ConnectionParams

        foreach ($Row in @($Response.result)) {
            [pscustomobject]@{
                PSTypeName = 'ServiceNow.API.CatalogVariable'
                Name       = $Row.'sc_item_option.item_option_new.name'
                Question   = $Row.'sc_item_option.item_option_new.question_text'
                Value      = $Row.'sc_item_option.value'
            }
        }
    }
}
