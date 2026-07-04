#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
    Pester tests for Get-ServiceNowAggregate.
#>

BeforeAll {
    Import-Module "$PSScriptRoot/../src/ServiceNow.API/ServiceNow.API.psd1" -Force
}

Describe 'Get-ServiceNowAggregate' {

    It 'requests a count from the stats endpoint' {
        Mock -ModuleName ServiceNow.API Invoke-ServiceNowApi { @{ result = @{ stats = @{ count = '42' } } } }
        $Result = Get-ServiceNowAggregate -Table incident -Count
        $Result.stats.count | Should -Be '42'
        Should -Invoke -ModuleName ServiceNow.API Invoke-ServiceNowApi -Times 1 -ParameterFilter {
            $Method -eq 'GET' -and $Path -eq 'api/now/stats/incident' -and $Query['sysparm_count'] -eq 'true'
        }
    }

    It 'groups by a field' {
        Mock -ModuleName ServiceNow.API Invoke-ServiceNowApi { @{ result = @() } }
        Get-ServiceNowAggregate -Table incident -Count -GroupBy priority
        Should -Invoke -ModuleName ServiceNow.API Invoke-ServiceNowApi -Times 1 -ParameterFilter {
            $Query['sysparm_group_by'] -eq 'priority'
        }
    }

    It 'builds an encoded query from -Filter' {
        Mock -ModuleName ServiceNow.API Invoke-ServiceNowApi { @{ result = @() } }
        Get-ServiceNowAggregate -Table incident -Count -Filter @('active', '-eq', 'true')
        Should -Invoke -ModuleName ServiceNow.API Invoke-ServiceNowApi -Times 1 -ParameterFilter {
            $Query['sysparm_query'] -eq 'active=true'
        }
    }

    It 'requests aggregate functions over fields' {
        Mock -ModuleName ServiceNow.API Invoke-ServiceNowApi { @{ result = @() } }
        Get-ServiceNowAggregate -Table incident -Average reassignment_count -Maximum reassignment_count
        Should -Invoke -ModuleName ServiceNow.API Invoke-ServiceNowApi -Times 1 -ParameterFilter {
            $Query['sysparm_avg_fields'] -eq 'reassignment_count' -and $Query['sysparm_max_fields'] -eq 'reassignment_count'
        }
    }
}
