function Get-ServiceNowUser {
    <#
        .SYNOPSIS
        Retrieves user (sys_user) records.

        .DESCRIPTION
        A convenience wrapper around Get-ServiceNowRecord for the 'sys_user' table. It accepts all the
        same filtering, field selection, sorting, pagination and connection parameters. Look users up
        by any field with -Query or -Filter (for example user_name, email or employee_number).

        .EXAMPLE
        Get-ServiceNowUser -Query 'user_name=abel.tuter'

        Get a user by their user name.

        .EXAMPLE
        Get-ServiceNowUser -Filter @('active', '-eq', 'true'), 'and', @('title', '-like', 'manager') -Fields name, email

        Find active users whose title contains 'manager'.

        .OUTPUTS
        The matching user record(s).

        .LINK
        https://github.com/deanlongstaff/ServiceNow.API
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param()

    DynamicParam { Import-ServiceNowTemplateParameter -TemplateFunction 'Get-ServiceNowRecord' -Exclude 'Table' }

    process {
        $Forward = @{}
        foreach ($Key in $PSBoundParameters.Keys) {
            $Forward[$Key] = $PSBoundParameters[$Key]
        }

        Get-ServiceNowRecord -Table 'sys_user' @Forward
    }
}
