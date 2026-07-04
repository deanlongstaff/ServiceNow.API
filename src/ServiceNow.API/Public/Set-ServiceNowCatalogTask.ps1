function Set-ServiceNowCatalogTask {
    <#
        .SYNOPSIS
        Updates a catalog task (SCTASK) record.

        .DESCRIPTION
        A convenience wrapper around Set-ServiceNowRecord for the 'sc_task' table. It accepts the same
        -Sys_ID, -InputData, -InputDisplayValue, -PassThru, -Instance and -Connection parameters, and
        supports the pipeline.

        .EXAMPLE
        Set-ServiceNowCatalogTask -Sys_ID $sysId -InputData @{ state = 3; work_notes = 'Provisioned' }

        Close a catalog task.

        .EXAMPLE
        Get-ServiceNowCatalogTask -Query 'active=true^assigned_to=NULL' | Set-ServiceNowCatalogTask -InputData @{ assignment_group = 'Fulfilment' }

        Assign all unassigned open catalog tasks via the pipeline.

        .OUTPUTS
        None by default, or the updated catalog task when -PassThru is used.

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

        $Target = "sc_task/$($PSBoundParameters['Sys_ID'])"
        if ($PSCmdlet.ShouldProcess($Target, 'Update ServiceNow record')) {
            Set-ServiceNowRecord -Table 'sc_task' @Forward -Confirm:$false
        }
    }
}
