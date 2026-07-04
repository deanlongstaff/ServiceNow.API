<#
    ServiceNow.API root module.

    Dot-sources every private helper and public function, then exports only the public functions.
    Private helpers live under Private/ and are intentionally not exported.
#>

# -- Module-scoped session context. Populated by Connect-ServiceNow and read by the API helpers.
#    Connections are keyed by instance name; the default is used when none is specified per-call.
$script:ServiceNowConnections = @{}
$script:ServiceNowDefaultInstance = $null

# -- Import all function files (private first so public functions can use them).
$Private = @(Get-ChildItem -Path (Join-Path $PSScriptRoot 'Private/*.ps1') -ErrorAction SilentlyContinue)
$Public = @(Get-ChildItem -Path (Join-Path $PSScriptRoot 'Public/*.ps1') -ErrorAction SilentlyContinue)

foreach ($File in @($Private + $Public)) {
    try {
        . $File.FullName
    }
    catch {
        throw "Failed to import function file '$($File.FullName)': $($_.Exception.Message)"
    }
}

Export-ModuleMember -Function $Public.BaseName -Alias @('Update-ServiceNowRecord', 'gsnr')
