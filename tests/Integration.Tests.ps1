#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
    Pester tests for Get-ServiceNowKnowledgeArticle, Get-ServiceNowTableSchema,
    Import-ServiceNowRecord and Invoke-ServiceNowRestMethod.
#>

BeforeAll {
    Import-Module "$PSScriptRoot/../src/ServiceNow.API/ServiceNow.API.psd1" -Force
}

Describe 'Get-ServiceNowKnowledgeArticle' {

    It 'searches articles and returns the articles collection' {
        Mock -ModuleName ServiceNow.API Invoke-ServiceNowApi {
            @{ result = @{ articles = @(@{ number = 'KB0001' }, @{ number = 'KB0002' }) } }
        }
        $Result = Get-ServiceNowKnowledgeArticle -Query 'vpn'
        $Result.Count | Should -Be 2
        Should -Invoke -ModuleName ServiceNow.API Invoke-ServiceNowApi -Times 1 -ParameterFilter {
            $Path -eq 'api/sn_km_api/knowledge/articles' -and $Query['query'] -eq 'vpn'
        }
    }

    It 'gets a single article by id' {
        Mock -ModuleName ServiceNow.API Invoke-ServiceNowApi { @{ result = @{ number = 'KB0001' } } }
        Get-ServiceNowKnowledgeArticle -ArticleId 'KB0001'
        Should -Invoke -ModuleName ServiceNow.API Invoke-ServiceNowApi -Times 1 -ParameterFilter {
            $Path -eq 'api/sn_km_api/knowledge/articles/KB0001'
        }
    }
}

Describe 'Get-ServiceNowTableSchema' {

    It 'reads sys_dictionary and projects readable column definitions' {
        Mock -ModuleName ServiceNow.API Invoke-ServiceNowApi {
            @{
                result = @(
                    @{
                        element        = @{ value = 'short_description'; display_value = 'short_description' }
                        column_label   = @{ value = 'Short description'; display_value = 'Short description' }
                        internal_type  = @{ value = 'abc'; display_value = 'String' }
                        reference      = @{ value = ''; display_value = '' }
                        mandatory      = @{ value = 'true'; display_value = 'true' }
                        read_only      = @{ value = 'false'; display_value = 'false' }
                        max_length     = @{ value = '160'; display_value = '160' }
                        default_value  = @{ value = ''; display_value = '' }
                        active         = @{ value = 'true'; display_value = 'true' }
                    }
                )
            }
        }
        $Result = Get-ServiceNowTableSchema -Table incident
        $Result.Element | Should -Be 'short_description'
        $Result.Type | Should -Be 'String'
        $Result.Mandatory | Should -Be 'true'
        Should -Invoke -ModuleName ServiceNow.API Invoke-ServiceNowApi -Times 1 -ParameterFilter {
            $Path -eq 'api/now/table/sys_dictionary' -and $Query['sysparm_query'] -like 'name=incident*'
        }
    }
}

Describe 'Import-ServiceNowRecord' {

    It 'posts to the import staging table' {
        Mock -ModuleName ServiceNow.API Invoke-ServiceNowApi { @{ result = @{ status = 'inserted' } } }
        $Result = Import-ServiceNowRecord -StagingTable 'u_imp_user' -InputData @{ u_name = 'jdoe' } -PassThru
        $Result.status | Should -Be 'inserted'
        Should -Invoke -ModuleName ServiceNow.API Invoke-ServiceNowApi -Times 1 -ParameterFilter {
            $Method -eq 'POST' -and $Path -eq 'api/now/import/u_imp_user'
        }
    }
}

Describe 'Invoke-ServiceNowRestMethod' {

    It 'passes a GET through to the engine' {
        Mock -ModuleName ServiceNow.API Invoke-ServiceNowApi { @{ result = @() } }
        Invoke-ServiceNowRestMethod -Path 'api/now/table/incident' -Query @{ sysparm_limit = 1 }
        Should -Invoke -ModuleName ServiceNow.API Invoke-ServiceNowApi -Times 1 -ParameterFilter {
            $Method -eq 'GET' -and $Path -eq 'api/now/table/incident' -and $Query['sysparm_limit'] -eq 1
        }
    }

    It 'passes a POST body through to the engine' {
        Mock -ModuleName ServiceNow.API Invoke-ServiceNowApi { @{ result = @{} } }
        Invoke-ServiceNowRestMethod -Method POST -Path 'api/now/table/incident' -Body @{ short_description = 'x' }
        Should -Invoke -ModuleName ServiceNow.API Invoke-ServiceNowApi -Times 1 -ParameterFilter {
            $Method -eq 'POST' -and $Body['short_description'] -eq 'x'
        }
    }
}
