function Set-ServiceNowChangeTask {
    <#
        .SYNOPSIS
        Updates a change task.

        .DESCRIPTION
        A convenience wrapper around Set-ServiceNowRecord for the 'change_task' table. It accepts the
        same -Sys_ID, -InputData, -InputDisplayValue, -PassThru, -Instance and -Connection parameters,
        and supports the pipeline.

        .EXAMPLE
        Set-ServiceNowChangeTask -Sys_ID $sysId -InputData @{ state = 3; work_notes = 'Completed' }

        Close a change task.

        .OUTPUTS
        None by default, or the updated change task when -PassThru is used.

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

        $Target = "change_task/$($PSBoundParameters['Sys_ID'])"
        if ($PSCmdlet.ShouldProcess($Target, 'Update ServiceNow record')) {
            Set-ServiceNowRecord -Table 'change_task' @Forward -Confirm:$false
        }
    }
}
