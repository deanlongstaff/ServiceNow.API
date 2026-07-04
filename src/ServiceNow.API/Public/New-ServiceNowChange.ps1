function New-ServiceNowChange {
    <#
        .SYNOPSIS
        Creates a change request through the Change Management API.

        .DESCRIPTION
        Creates a change through the dedicated Change Management API (sn_chg_rest), which applies the
        change model and its defaults. Use -Type to choose 'normal', 'standard' or 'emergency'. A
        standard change is created from a template, so -Template (the standard change template sys_id)
        is required for that type. Supply any additional field values with -InputData.

        This is distinct from New-ServiceNowRecord/New-ServiceNowChangeRequest, which write directly to
        the change_request table via the Table API. Use this cmdlet when you want the Change Management
        API's model handling (for example, creating a standard change from a template).

        .PARAMETER Type
        The change type: 'normal' (default), 'standard' or 'emergency'.

        .PARAMETER Template
        The sys_id of the standard change template. Required when -Type is 'standard'.

        .PARAMETER InputData
        A hashtable of additional field values for the change.

        .PARAMETER PassThru
        Return the created change.

        .PARAMETER Instance
        The name of a connected instance to target, instead of the default connection.

        .PARAMETER Connection
        An explicit connection object, overriding the connected session.

        .EXAMPLE
        New-ServiceNowChange -Type normal -InputData @{ short_description = 'Upgrade firmware' } -PassThru

        Create a normal change and return it.

        .EXAMPLE
        New-ServiceNowChange -Type standard -Template $templateSysId -PassThru

        Create a standard change from a template.

        .OUTPUTS
        None by default, or the created change when -PassThru is used.

        .LINK
        https://github.com/deanlongstaff/ServiceNow.API
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([pscustomobject])]
    param(
        [Parameter()]
        [ValidateSet('normal', 'standard', 'emergency')]
        [string]$Type = 'normal',

        [Parameter()]
        [string]$Template,

        [Parameter()]
        [Alias('Values', 'Properties')]
        [hashtable]$InputData,

        [Parameter()]
        [switch]$PassThru,

        [Parameter()]
        [string]$Instance,

        [Parameter()]
        [hashtable]$Connection
    )

    $ConnectionParams = @{}
    if ($PSBoundParameters.ContainsKey('Connection')) { $ConnectionParams['Connection'] = $Connection }
    if ($PSBoundParameters.ContainsKey('Instance')) { $ConnectionParams['Instance'] = $Instance }

    if ($Type -eq 'standard') {
        if ([string]::IsNullOrWhiteSpace($Template)) {
            throw 'A -Template (standard change template sys_id) is required when -Type is standard.'
        }
        $Path = "api/sn_chg_rest/change/standard/$Template"
    }
    else {
        $Path = "api/sn_chg_rest/change/$Type"
    }

    $Body = if ($InputData) { $InputData } else { @{} }

    if ($PSCmdlet.ShouldProcess("$Type change", 'Create change via Change Management API')) {
        $Response = Invoke-ServiceNowApi -Method 'POST' -Path $Path -Body $Body @ConnectionParams
        if ($PassThru) { return $Response.result }
    }
}
