#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
    Pester tests for the private request engine Invoke-ServiceNowApi, focusing on URI/query building,
    body serialisation and the rate-limit (429), transient (5xx) and 401 retry behaviour. The
    connection is provided by mocking Resolve-ServiceNowConnection so these tests are independent of
    how connections are stored.
#>

BeforeAll {
    Import-Module "$PSScriptRoot/../src/ServiceNow.API/ServiceNow.API.psd1" -Force
}

Describe 'Invoke-ServiceNowApi' {

    Context 'Request construction' {

        It 'builds the URI from the base URL and path' {
            InModuleScope ServiceNow.API {
                Mock Resolve-ServiceNowConnection { @{ BaseUrl = 'https://dev.service-now.com'; AuthType = 'Basic'; MaxRetry = 3; RetryDelaySeconds = 1 } }
                Mock New-ServiceNowAuthHeader { @{ Authorization = 'Basic x' } }
                Mock Invoke-RestMethod { @{ result = @() } }

                Invoke-ServiceNowApi -Method 'GET' -Path 'api/now/table/incident'

                Should -Invoke Invoke-RestMethod -Times 1 -ParameterFilter {
                    $Uri -eq 'https://dev.service-now.com/api/now/table/incident'
                }
            }
        }

        It 'appends and URL-encodes query parameters' {
            InModuleScope ServiceNow.API {
                Mock Resolve-ServiceNowConnection { @{ BaseUrl = 'https://dev.service-now.com'; AuthType = 'Basic'; MaxRetry = 3; RetryDelaySeconds = 1 } }
                Mock New-ServiceNowAuthHeader { @{ Authorization = 'Basic x' } }
                Mock Invoke-RestMethod { @{ result = @() } }

                Invoke-ServiceNowApi -Method 'GET' -Path 'api/now/table/incident' -Query @{ sysparm_query = 'active=true' }

                Should -Invoke Invoke-RestMethod -Times 1 -ParameterFilter {
                    $Uri -like '*?sysparm_query=active%3Dtrue'
                }
            }
        }

        It 'serialises a hashtable body to JSON' {
            InModuleScope ServiceNow.API {
                Mock Resolve-ServiceNowConnection { @{ BaseUrl = 'https://dev.service-now.com'; AuthType = 'Basic'; MaxRetry = 3; RetryDelaySeconds = 1 } }
                Mock New-ServiceNowAuthHeader { @{ Authorization = 'Basic x' } }
                Mock Invoke-RestMethod { @{ result = @{} } }

                Invoke-ServiceNowApi -Method 'POST' -Path 'api/now/table/incident' -Body @{ short_description = 'test' }

                Should -Invoke Invoke-RestMethod -Times 1 -ParameterFilter {
                    $Body -match '"short_description"\s*:\s*"test"'
                }
            }
        }
    }

    Context 'Rate limiting and transient errors' {

        It 'retries after HTTP 429 and then succeeds' {
            InModuleScope ServiceNow.API {
                Mock Resolve-ServiceNowConnection { @{ BaseUrl = 'https://dev.service-now.com'; AuthType = 'Basic'; MaxRetry = 3; RetryDelaySeconds = 1 } }
                Mock New-ServiceNowAuthHeader { @{ Authorization = 'Basic x' } }
                Mock Start-Sleep { }
                Mock Get-ServiceNowResponseDetail { [pscustomobject]@{ StatusCode = 429; Body = $null; Message = 'rate limited'; RetryAfterSeconds = $null } }

                $script:Attempts = 0
                Mock Invoke-RestMethod {
                    $script:Attempts++
                    if ($script:Attempts -eq 1) { throw 'rate limited' }
                    return @{ ok = $true }
                }

                $Result = Invoke-ServiceNowApi -Method 'GET' -Path 'api/now/table/incident'
                $Result.ok | Should -BeTrue
                Should -Invoke Invoke-RestMethod -Times 2
                Should -Invoke Start-Sleep -Times 1
            }
        }

        It 'retries HTTP 503 with backoff and then succeeds' {
            InModuleScope ServiceNow.API {
                Mock Resolve-ServiceNowConnection { @{ BaseUrl = 'https://dev.service-now.com'; AuthType = 'Basic'; MaxRetry = 3; RetryDelaySeconds = 1 } }
                Mock New-ServiceNowAuthHeader { @{ Authorization = 'Basic x' } }
                Mock Start-Sleep { }
                Mock Get-ServiceNowResponseDetail { [pscustomobject]@{ StatusCode = 503; Body = $null; Message = 'unavailable'; RetryAfterSeconds = $null } }

                $script:Attempts = 0
                Mock Invoke-RestMethod {
                    $script:Attempts++
                    if ($script:Attempts -lt 3) { throw 'unavailable' }
                    return @{ ok = $true }
                }

                $Result = Invoke-ServiceNowApi -Method 'GET' -Path 'api/now/table/incident'
                $Result.ok | Should -BeTrue
                Should -Invoke Invoke-RestMethod -Times 3
            }
        }

        It 'throws after exhausting retries on repeated 429' {
            InModuleScope ServiceNow.API {
                Mock Resolve-ServiceNowConnection { @{ BaseUrl = 'https://dev.service-now.com'; AuthType = 'Basic'; MaxRetry = 2; RetryDelaySeconds = 1 } }
                Mock New-ServiceNowAuthHeader { @{ Authorization = 'Basic x' } }
                Mock Start-Sleep { }
                Mock Get-ServiceNowResponseDetail { [pscustomobject]@{ StatusCode = 429; Body = $null; Message = 'rate limited'; RetryAfterSeconds = $null } }
                Mock Invoke-RestMethod { throw 'rate limited' }

                { Invoke-ServiceNowApi -Method 'GET' -Path 'api/now/table/incident' } | Should -Throw '*HTTP 429*'
                Should -Invoke Invoke-RestMethod -Times 3
            }
        }

        It 'does not retry a non-transient error such as 400' {
            InModuleScope ServiceNow.API {
                Mock Resolve-ServiceNowConnection { @{ BaseUrl = 'https://dev.service-now.com'; AuthType = 'Basic'; MaxRetry = 3; RetryDelaySeconds = 1 } }
                Mock New-ServiceNowAuthHeader { @{ Authorization = 'Basic x' } }
                Mock Start-Sleep { }
                Mock Get-ServiceNowResponseDetail { [pscustomobject]@{ StatusCode = 400; Body = $null; Message = 'bad request'; RetryAfterSeconds = $null } }
                Mock Invoke-RestMethod { throw 'bad request' }

                { Invoke-ServiceNowApi -Method 'GET' -Path 'api/now/table/incident' } | Should -Throw '*HTTP 400*'
                Should -Invoke Invoke-RestMethod -Times 1
            }
        }

        It 'refreshes the token once on 401 and retries' {
            InModuleScope ServiceNow.API {
                Mock Resolve-ServiceNowConnection { @{ BaseUrl = 'https://dev.service-now.com'; AuthType = 'OAuth'; MaxRetry = 3; RetryDelaySeconds = 1 } }
                Mock New-ServiceNowAuthHeader { @{ Authorization = 'Bearer x' } }
                Mock Get-ServiceNowResponseDetail { [pscustomobject]@{ StatusCode = 401; Body = $null; Message = 'unauthorized'; RetryAfterSeconds = $null } }

                $script:Attempts = 0
                Mock Invoke-RestMethod {
                    $script:Attempts++
                    if ($script:Attempts -eq 1) { throw 'unauthorized' }
                    return @{ ok = $true }
                }

                $Result = Invoke-ServiceNowApi -Method 'GET' -Path 'api/now/table/incident'
                $Result.ok | Should -BeTrue
                Should -Invoke Invoke-RestMethod -Times 2
                Should -Invoke New-ServiceNowAuthHeader -Times 1 -ParameterFilter { $ForceRefresh -eq $true }
            }
        }
    }

    Context 'Connection selection' {

        It 'passes -Instance through to the resolver' {
            InModuleScope ServiceNow.API {
                Mock Resolve-ServiceNowConnection { @{ BaseUrl = 'https://dev.service-now.com'; AuthType = 'Basic'; MaxRetry = 3; RetryDelaySeconds = 1 } }
                Mock New-ServiceNowAuthHeader { @{ Authorization = 'Basic x' } }
                Mock Invoke-RestMethod { @{ result = @() } }

                Invoke-ServiceNowApi -Method 'GET' -Path 'api/now/table/incident' -Instance 'prod'

                Should -Invoke Resolve-ServiceNowConnection -Times 1 -ParameterFilter { $Instance -eq 'prod' }
            }
        }
    }

    Context 'Raw responses' {

        It 'returns raw bytes with -Raw' {
            InModuleScope ServiceNow.API {
                Mock Resolve-ServiceNowConnection { @{ BaseUrl = 'https://dev.service-now.com'; AuthType = 'Basic'; MaxRetry = 3; RetryDelaySeconds = 1 } }
                Mock New-ServiceNowAuthHeader { @{ Authorization = 'Basic x' } }
                Mock Invoke-WebRequest { [pscustomobject]@{ Content = [byte[]]@(1, 2, 3) } }

                $Bytes = Invoke-ServiceNowApi -Method 'GET' -Path 'api/now/attachment/abc/file' -Raw
                $Bytes | Should -Be ([byte[]]@(1, 2, 3))
                Should -Invoke Invoke-WebRequest -Times 1
            }
        }
    }
}
