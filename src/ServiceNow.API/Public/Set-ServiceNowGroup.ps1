function Set-ServiceNowGroup {
    <#
        .SYNOPSIS
        Updates a group.

        .DESCRIPTION
        A convenience wrapper around Set-ServiceNowRecord for the 'sys_user_group' table. It accepts
        the same -Sys_ID, -InputData, -InputDisplayValue, -PassThru, -Instance and -Connection
        parameters, and supports the pipeline.

        .EXAMPLE
        Set-ServiceNowGroup -Sys_ID $sysId -InputData @{ manager = $managerSysId }

        Set a group's manager.

        .OUTPUTS
        None by default, or the updated group when -PassThru is used.

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

        $Target = "sys_user_group/$($PSBoundParameters['Sys_ID'])"
        if ($PSCmdlet.ShouldProcess($Target, 'Update ServiceNow record')) {
            Set-ServiceNowRecord -Table 'sys_user_group' @Forward -Confirm:$false
        }
    }
}
