function Set-ServiceNowIncident {
    <#
        .SYNOPSIS
        Updates an incident.

        .DESCRIPTION
        A convenience wrapper around Set-ServiceNowRecord for the 'incident' table. It accepts the same
        -Sys_ID, -InputData, -InputDisplayValue, -PassThru, -Instance and -Connection parameters, and
        supports the pipeline.

        .EXAMPLE
        Set-ServiceNowIncident -Sys_ID $sysId -InputData @{ state = 6; close_notes = 'Resolved' }

        Resolve an incident.

        .EXAMPLE
        Get-ServiceNowIncident -Query 'active=true' | Set-ServiceNowIncident -InputData @{ work_notes = 'Triaged' }

        Update every active incident via the pipeline.

        .OUTPUTS
        None by default, or the updated incident when -PassThru is used.

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

        $Target = "incident/$($PSBoundParameters['Sys_ID'])"
        if ($PSCmdlet.ShouldProcess($Target, 'Update ServiceNow record')) {
            Set-ServiceNowRecord -Table 'incident' @Forward -Confirm:$false
        }
    }
}
