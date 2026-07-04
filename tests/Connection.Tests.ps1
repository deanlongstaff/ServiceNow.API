#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
    Pester tests for Connect-ServiceNow, Disconnect-ServiceNow, Get-ServiceNowConnection and the
    private Resolve-ServiceNowConnection helper.
#>

BeforeAll {
    Import-Module "$PSScriptRoot/../src/ServiceNow.API/ServiceNow.API.psd1" -Force
    $script:Cred = [pscredential]::new('admin', (ConvertTo-SecureString 'p@ssw0rd' -AsPlainText -Force))
    $script:Secret = ConvertTo-SecureString 'client-secret' -AsPlainText -Force
}

Describe 'ServiceNow connection' {

    AfterEach {
        Disconnect-ServiceNow -ErrorAction SilentlyContinue
    }

    Context 'Connect-ServiceNow - Basic' {

        It 'normalises a short instance name to a base URL' {
            Connect-ServiceNow -Instance 'dev12345' -Credential $script:Cred
            $Context = Get-ServiceNowConnection
            $Context.BaseUrl | Should -Be 'https://dev12345.service-now.com'
            $Context.Instance | Should -Be 'dev12345'
            $Context.AuthType | Should -Be 'Basic'
        }

        It 'accepts a full URL and trims it' {
            Connect-ServiceNow -Instance 'https://dev12345.service-now.com/' -Credential $script:Cred
            (Get-ServiceNowConnection).BaseUrl | Should -Be 'https://dev12345.service-now.com'
        }

        It 'accepts a custom hostname' {
            Connect-ServiceNow -Instance 'snow.contoso.com' -Credential $script:Cred
            $Context = Get-ServiceNowConnection
            $Context.BaseUrl | Should -Be 'https://snow.contoso.com'
            $Context.Instance | Should -Be 'snow'
        }

        It 'never exposes the password' {
            Connect-ServiceNow -Instance 'dev12345' -Credential $script:Cred
            $Context = Get-ServiceNowConnection
            $Context.UserName | Should -Be 'admin'
            ($Context | ConvertTo-Json) | Should -Not -Match 'p@ssw0rd'
        }

        It 'returns the context with -PassThru' {
            $Result = Connect-ServiceNow -Instance 'dev12345' -Credential $script:Cred -PassThru
            $Result.Instance | Should -Be 'dev12345'
        }
    }

    Context 'Connect-ServiceNow - OAuth' {

        It 'requests a token and stores the expiry' {
            Mock -ModuleName ServiceNow.API Get-ServiceNowToken {
                [pscustomobject]@{ access_token = 'abc123'; refresh_token = 'refresh123'; expires_in = 1800 }
            }

            Connect-ServiceNow -Instance 'dev12345' -Credential $script:Cred -ClientId 'client' -ClientSecret $script:Secret

            Should -Invoke -ModuleName ServiceNow.API Get-ServiceNowToken -Times 1
            $Context = Get-ServiceNowConnection
            $Context.AuthType | Should -Be 'OAuth'
            $Context.TokenExpiry | Should -Not -BeNullOrEmpty
        }

        It 'throws when no access token is returned' {
            Mock -ModuleName ServiceNow.API Get-ServiceNowToken { [pscustomobject]@{ error = 'invalid_grant' } }
            { Connect-ServiceNow -Instance 'dev12345' -Credential $script:Cred -ClientId 'client' -ClientSecret $script:Secret } |
                Should -Throw '*did not return an OAuth access token*'
        }
    }

    Context 'Connect-ServiceNow - Token' {

        It 'stores a pre-issued access token' {
            $Token = ConvertTo-SecureString 'pre-issued-token' -AsPlainText -Force
            Connect-ServiceNow -Instance 'dev12345' -AccessToken $Token
            (Get-ServiceNowConnection).AuthType | Should -Be 'Token'
        }
    }

    Context 'Multiple instances' {

        It 'connects to several instances and lists them with -All' {
            Connect-ServiceNow -Instance 'dev11111' -Credential $script:Cred
            Connect-ServiceNow -Instance 'dev22222' -Credential $script:Cred
            $All = Get-ServiceNowConnection -All
            @($All).Count | Should -Be 2
            ($All.Instance | Sort-Object) -join ',' | Should -Be 'dev11111,dev22222'
        }

        It 'makes the most recently connected instance the default' {
            Connect-ServiceNow -Instance 'dev11111' -Credential $script:Cred
            Connect-ServiceNow -Instance 'dev22222' -Credential $script:Cred
            $Default = Get-ServiceNowConnection
            $Default.Instance | Should -Be 'dev22222'
            $Default.IsDefault | Should -BeTrue
        }

        It 'returns a specific instance with -Instance' {
            Connect-ServiceNow -Instance 'dev11111' -Credential $script:Cred
            Connect-ServiceNow -Instance 'dev22222' -Credential $script:Cred
            (Get-ServiceNowConnection -Instance 'dev11111').BaseUrl | Should -Be 'https://dev11111.service-now.com'
        }

        It 'disconnects a single instance and promotes a remaining default' {
            Connect-ServiceNow -Instance 'dev11111' -Credential $script:Cred
            Connect-ServiceNow -Instance 'dev22222' -Credential $script:Cred
            Disconnect-ServiceNow -Instance 'dev22222'
            @(Get-ServiceNowConnection -All).Count | Should -Be 1
            (Get-ServiceNowConnection).Instance | Should -Be 'dev11111'
        }
    }

    Context 'Disconnect-ServiceNow and Get-ServiceNowConnection' {

        It 'returns $null when not connected' {
            Disconnect-ServiceNow -ErrorAction SilentlyContinue
            Get-ServiceNowConnection | Should -BeNullOrEmpty
        }

        It 'clears the stored connection' {
            Connect-ServiceNow -Instance 'dev12345' -Credential $script:Cred
            Disconnect-ServiceNow
            Get-ServiceNowConnection | Should -BeNullOrEmpty
        }
    }
}

Describe 'Resolve-ServiceNowConnection' {

    AfterEach {
        Disconnect-ServiceNow -ErrorAction SilentlyContinue
    }

    It 'throws when there is no connection and none is passed' {
        InModuleScope ServiceNow.API {
            $script:ServiceNowConnections = @{}
            $script:ServiceNowDefaultInstance = $null
            { Resolve-ServiceNowConnection } | Should -Throw '*Not connected to ServiceNow*'
        }
    }

    It 'prefers an explicit connection over the default' {
        InModuleScope ServiceNow.API {
            $script:ServiceNowConnections = @{ session = @{ BaseUrl = 'https://session.service-now.com'; Instance = 'session' } }
            $script:ServiceNowDefaultInstance = 'session'
            $Explicit = @{ BaseUrl = 'https://explicit.service-now.com' }
            (Resolve-ServiceNowConnection -Connection $Explicit).BaseUrl | Should -Be 'https://explicit.service-now.com'
        }
    }

    It 'falls back to the default connection' {
        InModuleScope ServiceNow.API {
            $script:ServiceNowConnections = @{ session = @{ BaseUrl = 'https://session.service-now.com'; Instance = 'session' } }
            $script:ServiceNowDefaultInstance = 'session'
            (Resolve-ServiceNowConnection).BaseUrl | Should -Be 'https://session.service-now.com'
        }
    }

    It 'resolves a named instance' {
        InModuleScope ServiceNow.API {
            $script:ServiceNowConnections = @{
                one = @{ BaseUrl = 'https://one.service-now.com'; Instance = 'one' }
                two = @{ BaseUrl = 'https://two.service-now.com'; Instance = 'two' }
            }
            $script:ServiceNowDefaultInstance = 'two'
            (Resolve-ServiceNowConnection -Instance 'one').BaseUrl | Should -Be 'https://one.service-now.com'
        }
    }

    It 'throws for an instance that is not connected, listing those that are' {
        InModuleScope ServiceNow.API {
            $script:ServiceNowConnections = @{ one = @{ BaseUrl = 'https://one.service-now.com'; Instance = 'one' } }
            $script:ServiceNowDefaultInstance = 'one'
            { Resolve-ServiceNowConnection -Instance 'missing' } | Should -Throw "*Not connected to ServiceNow instance 'missing'*one*"
        }
    }
}
