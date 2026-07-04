#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
    Pester tests for the table-specific helper cmdlets (thin wrappers over the generic Table API
    cmdlets), covering table targeting, the -Number shortcut, parameter forwarding and ShouldProcess.

    These mock the request engine (Invoke-ServiceNowApi) rather than the generic cmdlets, so the
    wrappers' DynamicParam blocks can still introspect the real Get/New/Set-ServiceNowRecord.
#>

BeforeAll {
    Import-Module "$PSScriptRoot/../src/ServiceNow.API/ServiceNow.API.psd1" -Force
}

$GetMap = @(
    @{ Cmd = 'Get-ServiceNowIncident'; ExpectedPath = 'api/now/table/incident' }
    @{ Cmd = 'Get-ServiceNowChangeRequest'; ExpectedPath = 'api/now/table/change_request' }
    @{ Cmd = 'Get-ServiceNowChangeTask'; ExpectedPath = 'api/now/table/change_task' }
    @{ Cmd = 'Get-ServiceNowProblem'; ExpectedPath = 'api/now/table/problem' }
    @{ Cmd = 'Get-ServiceNowRequest'; ExpectedPath = 'api/now/table/sc_request' }
    @{ Cmd = 'Get-ServiceNowRequestedItem'; ExpectedPath = 'api/now/table/sc_req_item' }
    @{ Cmd = 'Get-ServiceNowCatalogTask'; ExpectedPath = 'api/now/table/sc_task' }
    @{ Cmd = 'Get-ServiceNowUser'; ExpectedPath = 'api/now/table/sys_user' }
    @{ Cmd = 'Get-ServiceNowGroup'; ExpectedPath = 'api/now/table/sys_user_group' }
    @{ Cmd = 'Get-ServiceNowConfigurationItem'; ExpectedPath = 'api/now/table/cmdb_ci' }
)

Describe 'Table helper Get wrappers' {

    It 'delegates <Cmd> to the right table (<ExpectedPath>)' -ForEach $GetMap {
        Mock -ModuleName ServiceNow.API Invoke-ServiceNowApi { @{ result = @() } }
        & $Cmd
        $Expected = $ExpectedPath
        Should -Invoke -ModuleName ServiceNow.API Invoke-ServiceNowApi -Times 1 -ParameterFilter {
            $Method -eq 'GET' -and $Path -eq $Expected
        }
    }

    It 'turns -Number into a number query' {
        Mock -ModuleName ServiceNow.API Invoke-ServiceNowApi { @{ result = @() } }
        Get-ServiceNowIncident -Number 'INC0010023'
        Should -Invoke -ModuleName ServiceNow.API Invoke-ServiceNowApi -Times 1 -ParameterFilter {
            $Path -eq 'api/now/table/incident' -and $Query['sysparm_query'] -eq 'number=INC0010023'
        }
    }

    It 'forwards filter and field parameters' {
        Mock -ModuleName ServiceNow.API Invoke-ServiceNowApi { @{ result = @() } }
        Get-ServiceNowChangeRequest -Query 'active=true' -Limit 5 -Fields number, state
        Should -Invoke -ModuleName ServiceNow.API Invoke-ServiceNowApi -Times 1 -ParameterFilter {
            $Query['sysparm_query'] -eq 'active=true' -and $Query['sysparm_fields'] -eq 'number,state' -and $Query['sysparm_limit'] -eq 5
        }
    }

    It 'forwards -Instance' {
        Mock -ModuleName ServiceNow.API Invoke-ServiceNowApi { @{ result = @() } }
        Get-ServiceNowUser -Instance 'prod'
        Should -Invoke -ModuleName ServiceNow.API Invoke-ServiceNowApi -Times 1 -ParameterFilter {
            $Path -eq 'api/now/table/sys_user' -and $Instance -eq 'prod'
        }
    }

    It 'throws when -Number and -Filter are combined' {
        Mock -ModuleName ServiceNow.API Invoke-ServiceNowApi { @{ result = @() } }
        { Get-ServiceNowIncident -Number 'INC1' -Filter @('active', '-eq', 'true') } | Should -Throw '*either -Number or -Filter*'
    }
}

Describe 'Table helper New wrappers' {

    It 'delegates New-ServiceNowIncident to the incident table' {
        Mock -ModuleName ServiceNow.API Invoke-ServiceNowApi { @{ result = @{} } }
        New-ServiceNowIncident -InputData @{ short_description = 'test' }
        Should -Invoke -ModuleName ServiceNow.API Invoke-ServiceNowApi -Times 1 -ParameterFilter {
            $Method -eq 'POST' -and $Path -eq 'api/now/table/incident' -and $Body.short_description -eq 'test'
        }
    }

    It 'delegates New-ServiceNowUser to the sys_user table' {
        Mock -ModuleName ServiceNow.API Invoke-ServiceNowApi { @{ result = @{} } }
        New-ServiceNowUser -InputData @{ user_name = 'jdoe' }
        Should -Invoke -ModuleName ServiceNow.API Invoke-ServiceNowApi -Times 1 -ParameterFilter {
            $Method -eq 'POST' -and $Path -eq 'api/now/table/sys_user'
        }
    }

    It 'does not create when -WhatIf is used' {
        Mock -ModuleName ServiceNow.API Invoke-ServiceNowApi { @{ result = @{} } }
        New-ServiceNowIncident -InputData @{ short_description = 'test' } -WhatIf
        Should -Invoke -ModuleName ServiceNow.API Invoke-ServiceNowApi -Times 0
    }
}

Describe 'Table helper Set wrappers' {

    It 'delegates Set-ServiceNowIncident to the incident table' {
        Mock -ModuleName ServiceNow.API Invoke-ServiceNowApi { @{ result = @{} } }
        Set-ServiceNowIncident -Sys_ID 'abc' -InputData @{ state = 6 }
        Should -Invoke -ModuleName ServiceNow.API Invoke-ServiceNowApi -Times 1 -ParameterFilter {
            $Method -eq 'PATCH' -and $Path -eq 'api/now/table/incident/abc'
        }
    }

    It 'updates records piped in, forcing the wrapper table' {
        Mock -ModuleName ServiceNow.API Invoke-ServiceNowApi { @{ result = @{} } }
        [pscustomobject]@{ sys_id = 'xyz' } | Set-ServiceNowCatalogTask -InputData @{ state = 3 }
        Should -Invoke -ModuleName ServiceNow.API Invoke-ServiceNowApi -Times 1 -ParameterFilter {
            $Method -eq 'PATCH' -and $Path -eq 'api/now/table/sc_task/xyz'
        }
    }

    It 'does not update when -WhatIf is used' {
        Mock -ModuleName ServiceNow.API Invoke-ServiceNowApi { @{ result = @{} } }
        Set-ServiceNowIncident -Sys_ID 'abc' -InputData @{ state = 6 } -WhatIf
        Should -Invoke -ModuleName ServiceNow.API Invoke-ServiceNowApi -Times 0
    }
}
