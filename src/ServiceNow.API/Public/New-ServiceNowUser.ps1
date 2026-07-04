function New-ServiceNowUser {
    <#
        .SYNOPSIS
        Creates a user.

        .DESCRIPTION
        A convenience wrapper around New-ServiceNowRecord for the 'sys_user' table. It accepts the same
        -InputData, -InputDisplayValue, -PassThru, -Instance and -Connection parameters.

        .EXAMPLE
        New-ServiceNowUser -InputData @{ user_name = 'jdoe'; first_name = 'Jane'; last_name = 'Doe'; email = 'jdoe@example.com' } -PassThru

        Create a user and return it.

        .OUTPUTS
        None by default, or the created user when -PassThru is used.

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

        if ($PSCmdlet.ShouldProcess('sys_user', 'Create ServiceNow record')) {
            New-ServiceNowRecord -Table 'sys_user' @Forward -Confirm:$false
        }
    }
}
