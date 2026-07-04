function New-ServiceNowGroup {
    <#
        .SYNOPSIS
        Creates a group.

        .DESCRIPTION
        A convenience wrapper around New-ServiceNowRecord for the 'sys_user_group' table. It accepts
        the same -InputData, -InputDisplayValue, -PassThru, -Instance and -Connection parameters.

        .EXAMPLE
        New-ServiceNowGroup -InputData @{ name = 'Network Team'; description = 'Handles network incidents' } -PassThru

        Create a group and return it.

        .OUTPUTS
        None by default, or the created group when -PassThru is used.

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

        if ($PSCmdlet.ShouldProcess('sys_user_group', 'Create ServiceNow record')) {
            New-ServiceNowRecord -Table 'sys_user_group' @Forward -Confirm:$false
        }
    }
}
