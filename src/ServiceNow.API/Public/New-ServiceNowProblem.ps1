function New-ServiceNowProblem {
    <#
        .SYNOPSIS
        Creates a problem.

        .DESCRIPTION
        A convenience wrapper around New-ServiceNowRecord for the 'problem' table. It accepts the same
        -InputData, -InputDisplayValue, -PassThru, -Instance and -Connection parameters.

        .EXAMPLE
        New-ServiceNowProblem -InputData @{ short_description = 'Recurring VPN drops' } -PassThru

        Create a problem and return it.

        .OUTPUTS
        None by default, or the created problem when -PassThru is used.

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

        if ($PSCmdlet.ShouldProcess('problem', 'Create ServiceNow record')) {
            New-ServiceNowRecord -Table 'problem' @Forward -Confirm:$false
        }
    }
}
