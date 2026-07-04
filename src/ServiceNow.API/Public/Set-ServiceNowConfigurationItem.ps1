function Set-ServiceNowConfigurationItem {
    <#
        .SYNOPSIS
        Updates a configuration item.

        .DESCRIPTION
        A convenience wrapper around Set-ServiceNowRecord for the 'cmdb_ci' table. It accepts the same
        -Sys_ID, -InputData, -InputDisplayValue, -PassThru, -Instance and -Connection parameters, and
        supports the pipeline.

        .EXAMPLE
        Set-ServiceNowConfigurationItem -Sys_ID $sysId -InputData @{ operational_status = 6 }

        Mark a configuration item as retired.

        .OUTPUTS
        None by default, or the updated configuration item when -PassThru is used.

        .LINK
        https://github.com/deanlongstaff/ServiceNow.API
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([pscustomobject])]
    param()

    DynamicParam { Import-ServiceNowTemplateParameter -TemplateFunction 'Set-ServiceNowRecord' -Exclude 'Table' }

    process {
        $Forward = @{}
        foreach ($Key in $PSBoundParameters.Keys) {
            if ($Key -in @('WhatIf', 'Confirm')) { continue }
            $Forward[$Key] = $PSBoundParameters[$Key]
        }

        $Target = "cmdb_ci/$($PSBoundParameters['Sys_ID'])"
        if ($PSCmdlet.ShouldProcess($Target, 'Update ServiceNow record')) {
            Set-ServiceNowRecord -Table 'cmdb_ci' @Forward -Confirm:$false
        }
    }
}
