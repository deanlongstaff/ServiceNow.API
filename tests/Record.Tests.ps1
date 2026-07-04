#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
    Pester tests for the Table API cmdlets: Get/New/Set/Remove-ServiceNowRecord.
#>

BeforeAll {
    Import-Module "$PSScriptRoot/../src/ServiceNow.API/ServiceNow.API.psd1" -Force
}

Describe 'Get-ServiceNowRecord' {

    Context 'Single record' {

        It 'gets a record by sys_id' {
            Mock -ModuleName ServiceNow.API Invoke-ServiceNowApi { @{ result = @{ sys_id = 'abc'; number = 'INC001' } } }
            $Result = Get-ServiceNowRecord -Table incident -Sys_ID 'abc'
            $Result.number | Should -Be 'INC001'
            Should -Invoke -ModuleName ServiceNow.API Invoke-ServiceNowApi -Times 1 -ParameterFilter {
                $Method -eq 'GET' -and $Path -eq 'api/now/table/incident/abc'
            }
        }

        It 'returns nothing when the record is not found (404)' {
            Mock -ModuleName ServiceNow.API Invoke-ServiceNowApi {
                $ex = [System.Exception]::new('not found')
                $ex.Data['ServiceNowStatusCode'] = 404
                throw $ex
            }
            $Result = Get-ServiceNowRecord -Table incident -Sys_ID 'missing'
            $Result | Should -BeNullOrEmpty
        }
    }

    Context 'Listing records' {

        It 'passes a raw query through' {
            Mock -ModuleName ServiceNow.API Invoke-ServiceNowApi { @{ result = @(@{ sys_id = '1' }) } }
            Get-ServiceNowRecord -Table incident -Query 'active=true'
            Should -Invoke -ModuleName ServiceNow.API Invoke-ServiceNowApi -Times 1 -ParameterFilter {
                $Path -eq 'api/now/table/incident' -and $Query['sysparm_query'] -eq 'active=true'
            }
        }

        It 'builds an encoded query from -Filter' {
            Mock -ModuleName ServiceNow.API Invoke-ServiceNowApi { @{ result = @() } }
            Get-ServiceNowRecord -Table incident -Filter @('active', '-eq', 'true')
            Should -Invoke -ModuleName ServiceNow.API Invoke-ServiceNowApi -Times 1 -ParameterFilter {
                $Query['sysparm_query'] -eq 'active=true'
            }
        }

        It 'joins requested fields' {
            Mock -ModuleName ServiceNow.API Invoke-ServiceNowApi { @{ result = @() } }
            Get-ServiceNowRecord -Table incident -Fields number, short_description
            Should -Invoke -ModuleName ServiceNow.API Invoke-ServiceNowApi -Times 1 -ParameterFilter {
                $Query['sysparm_fields'] -eq 'number,short_description'
            }
        }

        It 'passes -Instance through to the engine' {
            Mock -ModuleName ServiceNow.API Invoke-ServiceNowApi { @{ result = @() } }
            Get-ServiceNowRecord -Table incident -Instance 'prod'
            Should -Invoke -ModuleName ServiceNow.API Invoke-ServiceNowApi -Times 1 -ParameterFilter {
                $Instance -eq 'prod'
            }
        }

        It 'follows pagination across pages' {
            InModuleScope ServiceNow.API {
                $script:Page = 0
                Mock Invoke-ServiceNowApi {
                    $script:Page++
                    if ($script:Page -eq 1) {
                        return @{ result = (1..1000 | ForEach-Object { @{ sys_id = "id-$_" } }) }
                    }
                    return @{ result = @(@{ sys_id = 'final' }) }
                }
                $Result = Get-ServiceNowRecord -Table incident
                $Result.Count | Should -Be 1001
                Should -Invoke Invoke-ServiceNowApi -Times 2
            }
        }

        It 'caps the number of records with -Limit' {
            Mock -ModuleName ServiceNow.API Invoke-ServiceNowApi { @{ result = (1..1000 | ForEach-Object { @{ sys_id = "id-$_" } }) } }
            $Result = Get-ServiceNowRecord -Table incident -Limit 5
            $Result.Count | Should -Be 5
            Should -Invoke -ModuleName ServiceNow.API Invoke-ServiceNowApi -Times 1 -ParameterFilter {
                $Query['sysparm_limit'] -eq 5
            }
        }
    }
}

Describe 'New-ServiceNowRecord' {

    It 'posts to the table and returns the record with -PassThru' {
        Mock -ModuleName ServiceNow.API Invoke-ServiceNowApi { @{ result = @{ sys_id = 'new'; number = 'INC100' } } }
        $Result = New-ServiceNowRecord -Table incident -InputData @{ short_description = 'test' } -PassThru
        $Result.number | Should -Be 'INC100'
        Should -Invoke -ModuleName ServiceNow.API Invoke-ServiceNowApi -Times 1 -ParameterFilter {
            $Method -eq 'POST' -and $Path -eq 'api/now/table/incident'
        }
    }

    It 'sets sysparm_input_display_value with -InputDisplayValue' {
        Mock -ModuleName ServiceNow.API Invoke-ServiceNowApi { @{ result = @{} } }
        New-ServiceNowRecord -Table incident -InputData @{ state = 'New' } -InputDisplayValue
        Should -Invoke -ModuleName ServiceNow.API Invoke-ServiceNowApi -Times 1 -ParameterFilter {
            $Query['sysparm_input_display_value'] -eq 'true'
        }
    }
}

Describe 'Set-ServiceNowRecord' {

    It 'patches the record by sys_id' {
        Mock -ModuleName ServiceNow.API Invoke-ServiceNowApi { @{ result = @{ sys_id = 'abc' } } }
        Set-ServiceNowRecord -Table incident -Sys_ID 'abc' -InputData @{ state = 6 }
        Should -Invoke -ModuleName ServiceNow.API Invoke-ServiceNowApi -Times 1 -ParameterFilter {
            $Method -eq 'PATCH' -and $Path -eq 'api/now/table/incident/abc'
        }
    }

    It 'is available under the Update-ServiceNowRecord alias' {
        Mock -ModuleName ServiceNow.API Invoke-ServiceNowApi { @{ result = @{} } }
        Update-ServiceNowRecord -Table incident -Sys_ID 'abc' -InputData @{ state = 6 }
        Should -Invoke -ModuleName ServiceNow.API Invoke-ServiceNowApi -Times 1 -ParameterFilter {
            $Method -eq 'PATCH'
        }
    }

    It 'updates records piped from Get-ServiceNowRecord' {
        Mock -ModuleName ServiceNow.API Invoke-ServiceNowApi { @{ result = @{} } }
        [pscustomobject]@{ sys_class_name = 'incident'; sys_id = 'xyz' } | Set-ServiceNowRecord -InputData @{ work_notes = 'note' }
        Should -Invoke -ModuleName ServiceNow.API Invoke-ServiceNowApi -Times 1 -ParameterFilter {
            $Path -eq 'api/now/table/incident/xyz'
        }
    }
}

Describe 'Remove-ServiceNowRecord' {

    It 'deletes the record by sys_id' {
        Mock -ModuleName ServiceNow.API Invoke-ServiceNowApi { }
        Remove-ServiceNowRecord -Table incident -Sys_ID 'abc' -Confirm:$false
        Should -Invoke -ModuleName ServiceNow.API Invoke-ServiceNowApi -Times 1 -ParameterFilter {
            $Method -eq 'DELETE' -and $Path -eq 'api/now/table/incident/abc'
        }
    }
}
