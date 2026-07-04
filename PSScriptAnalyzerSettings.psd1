@{
    # PSScriptAnalyzer settings for the ServiceNow.API module.
    # See https://learn.microsoft.com/powershell/utility-modules/psscriptanalyzer/using-scriptanalyzer
    #
    # No IncludeRules is specified, so the full default rule set runs, filtered to the severities
    # below and configured by the Rules section.
    Severity = @('Error', 'Warning')

    Rules    = @{
        PSPlaceOpenBrace           = @{
            Enable     = $true
            OnSameLine = $true
        }
        PSUseConsistentIndentation = @{
            Enable          = $true
            IndentationSize = 4
            Kind            = 'space'
        }
    }
}
