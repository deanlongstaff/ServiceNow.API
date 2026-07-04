#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
    Pester tests for Invoke-ServiceNowBatch.
#>

BeforeAll {
    Import-Module "$PSScriptRoot/../src/ServiceNow.API/ServiceNow.API.psd1" -Force
}

Describe 'Invoke-ServiceNowBatch' {

    It 'posts to the batch endpoint and decodes serviced responses' {
        Mock -ModuleName ServiceNow.API Invoke-ServiceNowApi {
            $body = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes('{"result":{"number":"INC001"}}'))
            @{
                serviced_requests   = @(@{ id = 'a'; status_code = 200; body = $body; execution_time = 12 })
                unserviced_requests = @()
            }
        }

        $Result = Invoke-ServiceNowBatch -Request @(@{ Id = 'a'; Method = 'GET'; Url = '/api/now/table/incident?sysparm_limit=1' })

        $Result.Id | Should -Be 'a'
        $Result.StatusCode | Should -Be 200
        $Result.Serviced | Should -BeTrue
        $Result.Body.result.number | Should -Be 'INC001'

        Should -Invoke -ModuleName ServiceNow.API Invoke-ServiceNowApi -Times 1 -ParameterFilter {
            $Method -eq 'POST' -and $Path -eq 'api/now/v1/batch'
        }
    }

    It 'base64-encodes request bodies' {
        Mock -ModuleName ServiceNow.API Invoke-ServiceNowApi { @{ serviced_requests = @(); unserviced_requests = @() } }

        Invoke-ServiceNowBatch -Request @(@{ Id = 'b'; Method = 'POST'; Url = '/api/now/table/incident'; Body = @{ x = 1 } })

        Should -Invoke -ModuleName ServiceNow.API Invoke-ServiceNowApi -Times 1 -ParameterFilter {
            $Decoded = [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($Body.rest_requests[0].body))
            $Decoded -match '"x"\s*:\s*1'
        }
    }

    It 'reports unserviced requests' {
        Mock -ModuleName ServiceNow.API Invoke-ServiceNowApi {
            @{ serviced_requests = @(); unserviced_requests = @('c') }
        }
        $Result = Invoke-ServiceNowBatch -Request @(@{ Id = 'c'; Method = 'GET'; Url = '/api/now/table/incident' })
        $Result.Id | Should -Be 'c'
        $Result.Serviced | Should -BeFalse
    }

    It 'throws when a request is missing a Url' {
        Mock -ModuleName ServiceNow.API Invoke-ServiceNowApi { @{ serviced_requests = @(); unserviced_requests = @() } }
        { Invoke-ServiceNowBatch -Request @(@{ Id = 'd'; Method = 'GET' }) } | Should -Throw "*missing a 'Url'*"
    }
}
