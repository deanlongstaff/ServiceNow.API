function New-ServiceNowChangeRequest {
    <#
        .SYNOPSIS
        Creates a change request.

        .DESCRIPTION
        A convenience wrapper around New-ServiceNowRecord for the 'change_request' table. It accepts
        the same -InputData, -InputDisplayValue, -PassThru, -Instance and -Connection parameters.

        .EXAMPLE
        New-ServiceNowChangeRequest -InputData @{ short_description = 'Patch web servers'; type = 'normal' } -PassThru

        Create a normal change request and return it.

        .OUTPUTS
        None by default, or the created change request when -PassThru is used.

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

        if ($PSCmdlet.ShouldProcess('change_request', 'Create ServiceNow record')) {
            New-ServiceNowRecord -Table 'change_request' @Forward -Confirm:$false
        }
    }
}
