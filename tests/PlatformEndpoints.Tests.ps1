#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
    Pester tests for the additional platform endpoints: journal comments/work notes, catalog
    variables, GraphQL, record export, CMDB Instance API, Identification & Reconciliation, current
    user and the Change Management API.
#>

BeforeAll {
    Import-Module "$PSScriptRoot/../src/ServiceNow.API/ServiceNow.API.psd1" -Force
}

Describe 'Journal cmdlets' {

    It 'Add-ServiceNowComment patches the comments field' {
        Mock -ModuleName ServiceNow.API Invoke-ServiceNowApi { @{ result = @{} } }
        Add-ServiceNowComment -Table incident -Sys_ID 'abc' -Text 'Investigating'
        Should -Invoke -ModuleName ServiceNow.API Invoke-ServiceNowApi -Times 1 -ParameterFilter {
            $Method -eq 'PATCH' -and $Path -eq 'api/now/table/incident/abc' -and $Body.comments -eq 'Investigating'
        }
    }

    It 'Add-ServiceNowWorkNote patches the work_notes field' {
        Mock -ModuleName ServiceNow.API Invoke-ServiceNowApi { @{ result = @{} } }
        Add-ServiceNowWorkNote -Table incident -Sys_ID 'abc' -Text 'Restarted service'
        Should -Invoke -ModuleName ServiceNow.API Invoke-ServiceNowApi -Times 1 -ParameterFilter {
            $Method -eq 'PATCH' -and $Body.work_notes -eq 'Restarted service'
        }
    }

    It 'Get-ServiceNowJournalEntry queries sys_journal_field for the record' {
        Mock -ModuleName ServiceNow.API Invoke-ServiceNowApi { @{ result = @() } }
        Get-ServiceNowJournalEntry -Sys_ID 'abc' -Type work_notes
        Should -Invoke -ModuleName ServiceNow.API Invoke-ServiceNowApi -Times 1 -ParameterFilter {
            $Path -eq 'api/now/table/sys_journal_field' -and $Query['sysparm_query'] -like 'element_id=abc*element=work_notes*'
        }
    }

    It 'Add-ServiceNowComment does nothing with -WhatIf' {
        Mock -ModuleName ServiceNow.API Invoke-ServiceNowApi { @{ result = @{} } }
        Add-ServiceNowComment -Table incident -Sys_ID 'abc' -Text 'x' -WhatIf
        Should -Invoke -ModuleName ServiceNow.API Invoke-ServiceNowApi -Times 0
    }
}

Describe 'Get-ServiceNowCatalogVariable' {

    It 'reads the mtom join and projects Name/Question/Value' {
        Mock -ModuleName ServiceNow.API Invoke-ServiceNowApi {
            @{ result = @(
                    [pscustomobject]@{
                        'sc_item_option.item_option_new.name'          = 'colour'
                        'sc_item_option.item_option_new.question_text' = 'Colour?'
                        'sc_item_option.value'                         = 'black'
                    }
                ) }
        }
        $Result = Get-ServiceNowCatalogVariable -RequestedItemId 'ritm1'
        $Result.Name | Should -Be 'colour'
        $Result.Value | Should -Be 'black'
        Should -Invoke -ModuleName ServiceNow.API Invoke-ServiceNowApi -Times 1 -ParameterFilter {
            $Path -eq 'api/now/table/sc_item_option_mtom' -and $Query['sysparm_query'] -eq 'request_item=ritm1'
        }
    }
}

Describe 'Invoke-ServiceNowGraphQL' {

    It 'posts the query to the graphql endpoint and returns data' {
        Mock -ModuleName ServiceNow.API Invoke-ServiceNowApi { @{ data = @{ ok = $true } } }
        $Result = Invoke-ServiceNowGraphQL -Query 'query { x }'
        $Result.ok | Should -BeTrue
        Should -Invoke -ModuleName ServiceNow.API Invoke-ServiceNowApi -Times 1 -ParameterFilter {
            $Method -eq 'POST' -and $Path -eq 'api/now/graphql' -and $Body.query -eq 'query { x }'
        }
    }
}

Describe 'Export-ServiceNowRecord' {

    It 'requests the list export processor with the format from the extension' {
        Mock -ModuleName ServiceNow.API Invoke-ServiceNowApi { }
        Export-ServiceNowRecord -Table incident -Query 'active=true' -Path (Join-Path $TestDrive 'out.csv')
        Should -Invoke -ModuleName ServiceNow.API Invoke-ServiceNowApi -Times 1 -ParameterFilter {
            $Path -like 'incident_list.do?CSV*' -and $Path -like '*sysparm_query=active*' -and $OutFile -like '*out.csv'
        }
    }

    It 'throws on an unsupported extension' {
        Mock -ModuleName ServiceNow.API Invoke-ServiceNowApi { }
        { Export-ServiceNowRecord -Table incident -Path (Join-Path $TestDrive 'out.docx') } | Should -Throw '*Unsupported export extension*'
    }
}

Describe 'Get-ServiceNowCmdbInstance' {

    It 'gets a single CI with relationships by class and sys_id' {
        Mock -ModuleName ServiceNow.API Invoke-ServiceNowApi { @{ result = @{ sys_id = 'ci1' } } }
        Get-ServiceNowCmdbInstance -Class cmdb_ci_linux_server -Sys_ID 'ci1'
        Should -Invoke -ModuleName ServiceNow.API Invoke-ServiceNowApi -Times 1 -ParameterFilter {
            $Path -eq 'api/now/cmdb/instance/cmdb_ci_linux_server/ci1'
        }
    }

    It 'lists CIs of a class with a query' {
        Mock -ModuleName ServiceNow.API Invoke-ServiceNowApi { @{ result = @() } }
        Get-ServiceNowCmdbInstance -Class cmdb_ci_service -Query 'operational_status=1'
        Should -Invoke -ModuleName ServiceNow.API Invoke-ServiceNowApi -Times 1 -ParameterFilter {
            $Path -eq 'api/now/cmdb/instance/cmdb_ci_service' -and $Query['sysparm_query'] -eq 'operational_status=1'
        }
    }
}

Describe 'Invoke-ServiceNowIdentifyReconcile' {

    It 'posts the payload to the identifyreconcile endpoint' {
        Mock -ModuleName ServiceNow.API Invoke-ServiceNowApi { @{ result = @{} } }
        Invoke-ServiceNowIdentifyReconcile -InputData @{ items = @() } -DataSource 'MyIntegration'
        Should -Invoke -ModuleName ServiceNow.API Invoke-ServiceNowApi -Times 1 -ParameterFilter {
            $Method -eq 'POST' -and $Path -eq 'api/now/identifyreconcile' -and $Query['sysparm_data_source'] -eq 'MyIntegration'
        }
    }
}

Describe 'Get-ServiceNowCurrentUser' {

    It 'calls the current user endpoint' {
        Mock -ModuleName ServiceNow.API Invoke-ServiceNowApi { @{ result = @{ user_name = 'admin' } } }
        (Get-ServiceNowCurrentUser).user_name | Should -Be 'admin'
        Should -Invoke -ModuleName ServiceNow.API Invoke-ServiceNowApi -Times 1 -ParameterFilter {
            $Method -eq 'GET' -and $Path -eq 'api/now/ui/user/current_user'
        }
    }
}

Describe 'New-ServiceNowChange' {

    It 'creates a normal change via the Change Management API' {
        Mock -ModuleName ServiceNow.API Invoke-ServiceNowApi { @{ result = @{ number = 'CHG001' } } }
        New-ServiceNowChange -Type normal -InputData @{ short_description = 'x' }
        Should -Invoke -ModuleName ServiceNow.API Invoke-ServiceNowApi -Times 1 -ParameterFilter {
            $Method -eq 'POST' -and $Path -eq 'api/sn_chg_rest/change/normal'
        }
    }

    It 'creates a standard change from a template' {
        Mock -ModuleName ServiceNow.API Invoke-ServiceNowApi { @{ result = @{} } }
        New-ServiceNowChange -Type standard -Template 'tmpl1'
        Should -Invoke -ModuleName ServiceNow.API Invoke-ServiceNowApi -Times 1 -ParameterFilter {
            $Path -eq 'api/sn_chg_rest/change/standard/tmpl1'
        }
    }

    It 'requires a template for a standard change' {
        Mock -ModuleName ServiceNow.API Invoke-ServiceNowApi { @{ result = @{} } }
        { New-ServiceNowChange -Type standard } | Should -Throw '*Template*required*'
    }
}
