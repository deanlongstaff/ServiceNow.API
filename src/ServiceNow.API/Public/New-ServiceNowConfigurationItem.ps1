function New-ServiceNowConfigurationItem {
    <#
        .SYNOPSIS
        Creates a configuration item.

        .DESCRIPTION
        A convenience wrapper around New-ServiceNowRecord for the 'cmdb_ci' table. It accepts the same
        -InputData, -InputDisplayValue, -PassThru, -Instance and -Connection parameters. To create a
        record in a specific CMDB class, use New-ServiceNowRecord with that table name.

        .EXAMPLE
        New-ServiceNowConfigurationItem -InputData @{ name = 'APP-SVR-07'; operational_status = 1 } -PassThru

        Create a configuration item and return it.

        .OUTPUTS
        None by default, or the created configuration item when -PassThru is used.

        .LINK
        https://github.com/deanlongstaff/ServiceNow.API
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([pscustomobject])]
    param()

    DynamicParam { Import-ServiceNowTemplateParameter -TemplateFunction 'New-ServiceNowRecord' -Exclude 'Table' }

    process {
        $Forward = @{}
        foreach ($Key in $PSBoundParameters.Keys) {
            if ($Key -in @('WhatIf', 'Confirm')) { continue }
            $Forward[$Key] = $PSBoundParameters[$Key]
        }

        if ($PSCmdlet.ShouldProcess('cmdb_ci', 'Create ServiceNow record')) {
            New-ServiceNowRecord -Table 'cmdb_ci' @Forward -Confirm:$false
        }
    }
}
