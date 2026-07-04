function New-ServiceNowChangeTask {
    <#
        .SYNOPSIS
        Creates a change task.

        .DESCRIPTION
        A convenience wrapper around New-ServiceNowRecord for the 'change_task' table. It accepts the
        same -InputData, -InputDisplayValue, -PassThru, -Instance and -Connection parameters.

        .EXAMPLE
        New-ServiceNowChangeTask -InputData @{ change_request = $changeSysId; short_description = 'Take backup' } -PassThru

        Create a change task under a change request.

        .OUTPUTS
        None by default, or the created change task when -PassThru is used.

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

        if ($PSCmdlet.ShouldProcess('change_task', 'Create ServiceNow record')) {
            New-ServiceNowRecord -Table 'change_task' @Forward -Confirm:$false
        }
    }
}
