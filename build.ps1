<#
    .SYNOPSIS
    Build, lint, test, document and publish tasks for the ServiceNow.API module.

    .DESCRIPTION
    A dependency-light build script used locally and by CI. It installs Pester, PSScriptAnalyzer and
    platyPS on demand, runs static analysis and the Pester suite, generates Markdown and external
    (MAML) help, bumps the module version, stages the module for packaging, and publishes it to the
    PowerShell Gallery.

    .PARAMETER Task
    The task to run:
      - Test    (default) runs Analyze then the Pester suite.
      - Analyze runs PSScriptAnalyzer.
      - Docs    regenerates the Markdown help under docs/help.
      - Build   compiles the source into a single-file module (with external help) in the output folder.
      - Bump    increases the module version and updates the changelog.
      - Publish builds and publishes the module to the PowerShell Gallery.

    .PARAMETER BumpType
    For the Bump task, which part of the version to increase: 'Major', 'Minor' or 'Patch' (default).

    .PARAMETER Version
    For the Bump task, an explicit version to set, overriding -BumpType.

    .PARAMETER ApiKey
    The PowerShell Gallery API key, required for the Publish task.

    .PARAMETER OutputPath
    Where the Build task stages the module. Defaults to ./output.

    .EXAMPLE
    ./build.ps1 -Task Test

    .EXAMPLE
    ./build.ps1 -Task Docs

    .EXAMPLE
    ./build.ps1 -Task Bump -BumpType Minor

    .EXAMPLE
    ./build.ps1 -Task Publish -ApiKey $env:PSGALLERY_API_KEY
#>
[CmdletBinding()]
param(
    [ValidateSet('Test', 'Analyze', 'Docs', 'Build', 'Bump', 'Publish')]
    [string]$Task = 'Test',

    [ValidateSet('Major', 'Minor', 'Patch')]
    [string]$BumpType = 'Patch',

    [string]$Version,

    [string]$ApiKey,

    [string]$OutputPath = (Join-Path $PSScriptRoot 'output')
)

$ErrorActionPreference = 'Stop'

$ModuleName = 'ServiceNow.API'
$SourcePath = Join-Path $PSScriptRoot "src/$ModuleName"
$ManifestPath = Join-Path $SourcePath "$ModuleName.psd1"
$SettingsPath = Join-Path $PSScriptRoot 'PSScriptAnalyzerSettings.psd1'
$TestsPath = Join-Path $PSScriptRoot 'tests'
$DocsPath = Join-Path $PSScriptRoot 'docs/help'
$ChangelogPath = Join-Path $PSScriptRoot 'CHANGELOG.md'
$RepoUrl = 'https://github.com/deanlongstaff/ServiceNow.API'

# renovate: datasource=nuget depName=Pester
$PesterMinimum = [version]'5.5.0'
# renovate: datasource=nuget depName=PSScriptAnalyzer
$AnalyzerMinimum = [version]'1.21.0'
# renovate: datasource=nuget depName=platyPS
$PlatyPSMinimum = [version]'0.14.2'

function Install-BuildDependency {
    param(
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][version]$MinimumVersion
    )

    if (Get-Module -ListAvailable -Name $Name | Where-Object Version -GE $MinimumVersion) {
        return
    }

    Write-Host "Installing $Name (>= $MinimumVersion)..."
    if ($PSVersionTable.PSEdition -eq 'Desktop') {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Install-PackageProvider -Name NuGet -MinimumVersion '2.8.5.201' -Force -Scope CurrentUser | Out-Null
    }
    Install-Module -Name $Name -MinimumVersion $MinimumVersion -Scope CurrentUser -Force -SkipPublisherCheck
}

function Invoke-Analyze {
    Install-BuildDependency -Name 'PSScriptAnalyzer' -MinimumVersion $AnalyzerMinimum
    Import-Module PSScriptAnalyzer -Force

    Write-Host "Running PSScriptAnalyzer on $SourcePath..."
    $Results = Invoke-ScriptAnalyzer -Path $SourcePath -Recurse -Settings $SettingsPath

    if ($Results) {
        $Results | Format-Table -AutoSize | Out-String | Write-Host
        throw "PSScriptAnalyzer found $($Results.Count) issue(s)."
    }
    Write-Host 'PSScriptAnalyzer: no issues found.'
}

function Invoke-Test {
    Install-BuildDependency -Name 'Pester' -MinimumVersion $PesterMinimum
    Install-BuildDependency -Name 'PSScriptAnalyzer' -MinimumVersion $AnalyzerMinimum
    Import-Module Pester -MinimumVersion $PesterMinimum -Force

    $Configuration = New-PesterConfiguration
    $Configuration.Run.Path = $TestsPath
    $Configuration.Run.PassThru = $true
    $Configuration.Output.Verbosity = 'Detailed'
    $Configuration.TestResult.Enabled = $true
    $Configuration.TestResult.OutputPath = (Join-Path $PSScriptRoot 'testResults.xml')
    $Configuration.TestResult.OutputFormat = 'NUnitXml'
    $Configuration.CodeCoverage.Enabled = $true
    $Configuration.CodeCoverage.Path = (Get-ChildItem -Path $SourcePath -Recurse -Filter '*.ps1').FullName
    $Configuration.CodeCoverage.OutputPath = (Join-Path $PSScriptRoot 'coverage.xml')
    $Configuration.CodeCoverage.OutputFormat = 'JaCoCo'

    $Result = Invoke-Pester -Configuration $Configuration

    if ($Result.FailedCount -gt 0) {
        Write-Host "`n===== FAILED TESTS ($($Result.FailedCount)) ====="
        foreach ($Test in $Result.Failed) {
            Write-Host ("[-] {0}" -f $Test.ExpandedPath)
            $FailMessage = if ($Test.ErrorRecord) { [string]$Test.ErrorRecord.Exception.Message } else { '' }
            if ($FailMessage) { Write-Host ("    {0}" -f $FailMessage) }
        }
        Write-Host '================================'
        throw "$($Result.FailedCount) test(s) failed."
    }
    Write-Host "All $($Result.PassedCount) test(s) passed."
}

function Invoke-Docs {
    Install-BuildDependency -Name 'platyPS' -MinimumVersion $PlatyPSMinimum
    Import-Module platyPS -Force
    Import-Module $ManifestPath -Force

    if (-not (Test-Path $DocsPath)) {
        New-Item -ItemType Directory -Path $DocsPath -Force | Out-Null
    }

    # -- Regenerate the cmdlet Markdown deterministically from the comment-based help.
    New-MarkdownHelp -Module $ModuleName -OutputFolder $DocsPath -WithModulePage -AlphabeticParamsOrder -Force |
        Out-Null
    Write-Host "Markdown help written to $DocsPath."
}

function Build-ExternalHelp {
    param([Parameter(Mandatory)][string]$DestinationEnUs)

    Install-BuildDependency -Name 'platyPS' -MinimumVersion $PlatyPSMinimum
    Import-Module platyPS -Force

    $CmdletMarkdown = Get-ChildItem -Path $DocsPath -Filter '*.md' -ErrorAction SilentlyContinue |
        Where-Object Name -NE "$ModuleName.md"
    if (-not $CmdletMarkdown) {
        Invoke-Docs
    }

    if (-not (Test-Path $DestinationEnUs)) {
        New-Item -ItemType Directory -Path $DestinationEnUs -Force | Out-Null
    }

    # -- Compile the Markdown into MAML external help so Get-Help is rich and consistent.
    New-ExternalHelp -Path $DocsPath -OutputPath $DestinationEnUs -Force | Out-Null
    Write-Host "External help compiled to $DestinationEnUs."
}

function Build-RootModule {
    param([Parameter(Mandatory)][string]$DestinationPsm1)

    # -- Sort by name for a deterministic, cross-platform build order (matches PoshCode/ModuleBuilder).
    $Private = @(Get-ChildItem -Path (Join-Path $SourcePath 'Private/*.ps1') -ErrorAction SilentlyContinue | Sort-Object Name)
    $Public = @(Get-ChildItem -Path (Join-Path $SourcePath 'Public/*.ps1') -ErrorAction SilentlyContinue | Sort-Object Name)

    $Builder = [System.Text.StringBuilder]::new()

    # -- Header + module-scoped session context (helpers rely on it, so it must be declared first).
    [void]$Builder.AppendLine(@'
<#
    ServiceNow.API root module.

    GENERATED FILE - DO NOT EDIT.
    Compiled from the per-function source files under src/ServiceNow.API/Private and
    src/ServiceNow.API/Public by build.ps1. Edit those files, then re-run:
        pwsh -File ./build.ps1 -Task Build
#>

# -- Module-scoped session context. Populated by Connect-ServiceNow and read by the API helpers.
#    Connections are keyed by instance name; the default is used when none is specified per-call.
$script:ServiceNowConnections = @{}
$script:ServiceNowDefaultInstance = $null
'@)

    # -- Inline every function (private first so public functions can call them), wrapped in region
    #    markers naming the source file so errors, breakpoints and folding stay traceable.
    foreach ($File in @($Private + $Public)) {
        $Relative = 'src/{0}/{1}/{2}' -f $ModuleName, $File.Directory.Name, $File.Name
        $Content = (Get-Content -Path $File.FullName -Raw).TrimEnd()

        [void]$Builder.AppendLine()
        [void]$Builder.AppendLine("#region $Relative")
        [void]$Builder.AppendLine($Content)
        [void]$Builder.AppendLine("#endregion $Relative")
    }

    # -- Export only the public functions (one function per file, named after the file) plus aliases.
    [void]$Builder.AppendLine()
    [void]$Builder.AppendLine('Export-ModuleMember -Function @(')
    foreach ($Name in ($Public.BaseName | Sort-Object)) {
        [void]$Builder.AppendLine("    '$Name'")
    }
    [void]$Builder.AppendLine(") -Alias @('Update-ServiceNowRecord', 'gsnr')")

    # -- Write UTF-8 with BOM (read identically by PS 5.1 and 7) with normalised LF endings for a
    #    deterministic, signable artifact.
    $Text = ($Builder.ToString() -replace "`r`n", "`n")
    [System.IO.File]::WriteAllText($DestinationPsm1, $Text, [System.Text.UTF8Encoding]::new($true))

    Write-Host "Compiled $($Private.Count) private + $($Public.Count) public function file(s) into $DestinationPsm1."
}

function Invoke-Build {
    Write-Host "Validating manifest $ManifestPath..."
    Test-ModuleManifest -Path $ManifestPath | Out-Null

    $StagePath = Join-Path $OutputPath $ModuleName
    if (Test-Path $StagePath) {
        Remove-Item -Path $StagePath -Recurse -Force
    }
    New-Item -ItemType Directory -Path $StagePath -Force | Out-Null

    Write-Host "Compiling module to $StagePath..."

    # -- Compile all functions into one root module: best load performance and one signature/CRL
    #    check when signed. See PoshCode/ModuleBuilder 'ship your module as one big file'.
    Build-RootModule -DestinationPsm1 (Join-Path $StagePath "$ModuleName.psm1")

    # -- Copy the manifest as-is; RootModule already points at the compiled psm1.
    Copy-Item -Path $ManifestPath -Destination $StagePath -Force

    # -- Carry across any static help content (e.g. about_*.help.txt).
    $SourceEnUs = Join-Path $SourcePath 'en-US'
    if (Test-Path $SourceEnUs) {
        Copy-Item -Path $SourceEnUs -Destination $StagePath -Recurse -Force
    }

    Build-ExternalHelp -DestinationEnUs (Join-Path $StagePath 'en-US')

    return $StagePath
}

function Invoke-Bump {
    $Raw = Get-Content -Path $ManifestPath -Raw
    if ($Raw -notmatch "ModuleVersion\s*=\s*'([^']+)'") {
        throw 'Could not find ModuleVersion in the manifest.'
    }
    $Current = [version]$Matches[1]

    if ($Version) {
        $New = [version]$Version
    }
    else {
        switch ($BumpType) {
            'Major' { $New = [version]('{0}.0.0' -f ($Current.Major + 1)) }
            'Minor' { $New = [version]('{0}.{1}.0' -f $Current.Major, ($Current.Minor + 1)) }
            'Patch' { $New = [version]('{0}.{1}.{2}' -f $Current.Major, $Current.Minor, ([Math]::Max($Current.Build, 0) + 1)) }
        }
    }
    $NewVersion = $New.ToString()
    Write-Host "Bumping module version $Current -> $NewVersion"

    # -- Update the manifest version (targeted replace preserves formatting and comments).
    $Raw = $Raw -replace "(ModuleVersion\s*=\s*')[^']+(')", "`${1}$NewVersion`${2}"
    Set-Content -Path $ManifestPath -Value $Raw -NoNewline

    # -- Update the changelog: promote Unreleased to a dated version section and fix the links.
    if (Test-Path $ChangelogPath) {
        $Changelog = Get-Content -Path $ChangelogPath -Raw
        $Date = (Get-Date).ToString('yyyy-MM-dd')

        $Changelog = $Changelog -replace '## \[Unreleased\]', "## [Unreleased]`n`n## [$NewVersion] - $Date"
        $Changelog = $Changelog -replace 'compare/v[0-9]+\.[0-9]+\.[0-9]+\.\.\.HEAD', "compare/v$NewVersion...HEAD"

        $TagLink = "[$NewVersion]: $RepoUrl/releases/tag/v$NewVersion"
        if ($Changelog -notmatch [regex]::Escape($TagLink) -and $Changelog -match '(?m)^\[Unreleased\]:.*$') {
            $Changelog = $Changelog -replace [regex]::Escape($Matches[0]), "$($Matches[0])`n$TagLink"
        }

        Set-Content -Path $ChangelogPath -Value $Changelog -NoNewline
    }

    Write-Host "Module version is now $NewVersion."
    return $NewVersion
}

function Invoke-Publish {
    if ([string]::IsNullOrWhiteSpace($ApiKey)) {
        throw 'The Publish task requires -ApiKey (the PowerShell Gallery API key).'
    }

    $StagePath = Invoke-Build

    Write-Host "Publishing $ModuleName to the PowerShell Gallery..."
    Publish-Module -Path $StagePath -NuGetApiKey $ApiKey -Verbose
    Write-Host 'Publish complete.'
}

switch ($Task) {
    'Analyze' { Invoke-Analyze }
    'Test' {
        Invoke-Analyze
        Invoke-Test
    }
    'Docs' { Invoke-Docs }
    'Build' { Invoke-Build | Out-Null }
    'Bump' { Invoke-Bump | Out-Null }
    'Publish' { Invoke-Publish }
}
