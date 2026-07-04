function Set-ServiceNowProblem {
    <#
        .SYNOPSIS
        Updates a problem.

        .DESCRIPTION
        A convenience wrapper around Set-ServiceNowRecord for the 'problem' table. It accepts the same
        -Sys_ID, -InputData, -InputDisplayValue, -PassThru, -Instance and -Connection parameters, and
        supports the pipeline.

        .EXAMPLE
        Set-ServiceNowProblem -Sys_ID $sysId -InputData @{ state = 103; cause_notes = 'Faulty driver' }

        Mark a problem as known and record the cause.

        .OUTPUTS
        None by default, or the updated problem when -PassThru is used.

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

        $Target = "problem/$($PSBoundParameters['Sys_ID'])"
        if ($PSCmdlet.ShouldProcess($Target, 'Update ServiceNow record')) {
            Set-ServiceNowRecord -Table 'problem' @Forward -Confirm:$false
        }
    }
}
