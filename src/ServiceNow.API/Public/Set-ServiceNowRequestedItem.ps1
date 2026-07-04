function Set-ServiceNowRequestedItem {
    <#
        .SYNOPSIS
        Updates a requested item (RITM) record.

        .DESCRIPTION
        A convenience wrapper around Set-ServiceNowRecord for the 'sc_req_item' table. It accepts the
        same -Sys_ID, -InputData, -InputDisplayValue, -PassThru, -Instance and -Connection parameters,
        and supports the pipeline.

        .EXAMPLE
        Set-ServiceNowRequestedItem -Sys_ID $sysId -InputData @{ state = 3; stage = 'Delivery' }

        Move a requested item to the delivery stage.

        .OUTPUTS
        None by default, or the updated requested item when -PassThru is used.

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

        $Target = "sc_req_item/$($PSBoundParameters['Sys_ID'])"
        if ($PSCmdlet.ShouldProcess($Target, 'Update ServiceNow record')) {
            Set-ServiceNowRecord -Table 'sc_req_item' @Forward -Confirm:$false
        }
    }
}
