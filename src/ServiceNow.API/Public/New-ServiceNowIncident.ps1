function New-ServiceNowIncident {
    <#
        .SYNOPSIS
        Creates an incident.

        .DESCRIPTION
        A convenience wrapper around New-ServiceNowRecord for the 'incident' table. It accepts the same
        -InputData, -InputDisplayValue, -PassThru, -Instance and -Connection parameters.

        .EXAMPLE
        New-ServiceNowIncident -InputData @{ short_description = 'Printer offline'; urgency = 2 } -PassThru

        Create an incident and return it.

        .OUTPUTS
        None by default, or the created incident when -PassThru is used.

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

        if ($PSCmdlet.ShouldProcess('incident', 'Create ServiceNow record')) {
            New-ServiceNowRecord -Table 'incident' @Forward -Confirm:$false
        }
    }
}
