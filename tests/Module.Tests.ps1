#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
    Module-level quality tests: manifest validity, exported surface, comment-based help and linting.
#>

BeforeDiscovery {
    Import-Module "$PSScriptRoot/../src/ServiceNow.API/ServiceNow.API.psd1" -Force
    $ExportedCommands = (Get-Command -Module ServiceNow.API -CommandType Function).Name
}

BeforeAll {
    $script:ManifestPath = "$PSScriptRoot/../src/ServiceNow.API/ServiceNow.API.psd1"
    $script:ModulePath = "$PSScriptRoot/../src/ServiceNow.API"
    $script:SettingsPath = "$PSScriptRoot/../PSScriptAnalyzerSettings.psd1"
    Import-Module $script:ManifestPath -Force
}

Describe 'Module manifest' {

    It 'is a valid module manifest' {
        { Test-ModuleManifest -Path $script:ManifestPath -ErrorAction Stop } | Should -Not -Throw
    }

    It 'exports exactly the documented public commands' {
        $Exported = (Get-Command -Module ServiceNow.API -CommandType Function).Name
        $Exported.Count | Should -Be 60
    }

    It 'exports the documented aliases' {
        $Aliases = (Get-Command -Module ServiceNow.API -CommandType Alias).Name
        $Aliases | Should -Contain 'Update-ServiceNowRecord'
        $Aliases | Should -Contain 'gsnr'
    }

    It 'does not export private helpers' {
        Get-Command -Module ServiceNow.API -Name 'Invoke-ServiceNowApi' -ErrorAction SilentlyContinue | Should -BeNullOrEmpty
        Get-Command -Module ServiceNow.API -Name 'New-ServiceNowAuthHeader' -ErrorAction SilentlyContinue | Should -BeNullOrEmpty
        Get-Command -Module ServiceNow.API -Name 'Resolve-ServiceNowConnection' -ErrorAction SilentlyContinue | Should -BeNullOrEmpty
        Get-Command -Module ServiceNow.API -Name 'Import-ServiceNowTemplateParameter' -ErrorAction SilentlyContinue | Should -BeNullOrEmpty
    }
}

Describe 'Comment-based help' {

    It '<_> has a synopsis and at least one example' -ForEach $ExportedCommands {
        $Help = Get-Help -Name $_ -ErrorAction Stop
        $Help.Synopsis.Trim() | Should -Not -BeNullOrEmpty
        @($Help.Examples.Example).Count | Should -BeGreaterThan 0
    }
}

Describe 'Static analysis' {

    It 'passes PSScriptAnalyzer with no errors or warnings' -Skip:(-not (Get-Module -ListAvailable -Name PSScriptAnalyzer)) {
        Import-Module PSScriptAnalyzer -Force
        $Analysis = Invoke-ScriptAnalyzer -Path $script:ModulePath -Recurse -Settings $script:SettingsPath
        $Analysis | Should -BeNullOrEmpty -Because ("`n" + ($Analysis | Format-Table -AutoSize | Out-String))
    }
}
