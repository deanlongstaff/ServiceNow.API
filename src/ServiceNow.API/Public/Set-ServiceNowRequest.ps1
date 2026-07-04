function Set-ServiceNowRequest {
    <#
        .SYNOPSIS
        Updates a service catalog request (REQ) record.

        .DESCRIPTION
        A convenience wrapper around Set-ServiceNowRecord for the 'sc_request' table. It accepts the
        same -Sys_ID, -InputData, -InputDisplayValue, -PassThru, -Instance and -Connection parameters,
        and supports the pipeline.

        .EXAMPLE
        Set-ServiceNowRequest -Sys_ID $sysId -InputData @{ request_state = 'closed_complete' }

        Close a request.

        .OUTPUTS
        None by default, or the updated request when -PassThru is used.

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

        $Target = "sc_request/$($PSBoundParameters['Sys_ID'])"
        if ($PSCmdlet.ShouldProcess($Target, 'Update ServiceNow record')) {
            Set-ServiceNowRecord -Table 'sc_request' @Forward -Confirm:$false
        }
    }
}
