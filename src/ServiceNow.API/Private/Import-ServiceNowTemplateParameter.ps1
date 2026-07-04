function Import-ServiceNowTemplateParameter {
    <#
        .SYNOPSIS
        Clones a template cmdlet's parameters for use in a table-specific wrapper.

        .DESCRIPTION
        Internal helper used by the table-specific convenience cmdlets (for example
        Get-ServiceNowIncident) so they expose exactly the same parameters as the generic template
        cmdlet (Get-ServiceNowRecord, New-ServiceNowRecord or Set-ServiceNowRecord) without
        redeclaring them. This keeps the wrappers tiny and always in sync with the generic cmdlets.

        It returns a RuntimeDefinedParameterDictionary suitable for returning from a DynamicParam
        block. Common parameters (and, for the write cmdlets, WhatIf/Confirm) are omitted because the
        wrapper supplies its own.

        .PARAMETER TemplateFunction
        The generic cmdlet whose parameters should be cloned.

        .PARAMETER Exclude
        Parameter names to omit, for example 'Table', which the wrapper sets itself.

        .OUTPUTS
        System.Management.Automation.RuntimeDefinedParameterDictionary
    #>
    [CmdletBinding()]
    [OutputType([System.Management.Automation.RuntimeDefinedParameterDictionary])]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$TemplateFunction,

        [Parameter()]
        [string[]]$Exclude = @()
    )

    $Template = Get-Command -Name $TemplateFunction -Module 'ServiceNow.API' -ErrorAction Stop

    $Skip = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    foreach ($Name in $Exclude) { [void]$Skip.Add($Name) }
    foreach ($Name in [System.Management.Automation.Cmdlet]::CommonParameters) { [void]$Skip.Add($Name) }
    foreach ($Name in [System.Management.Automation.Cmdlet]::OptionalCommonParameters) { [void]$Skip.Add($Name) }

    $Dictionary = [System.Management.Automation.RuntimeDefinedParameterDictionary]::new()
    foreach ($Entry in $Template.Parameters.GetEnumerator()) {
        if ($Skip.Contains($Entry.Key)) { continue }

        $Source = $Entry.Value
        $Attributes = [System.Collections.ObjectModel.Collection[System.Attribute]]::new()
        foreach ($Attribute in $Source.Attributes) {
            $Attributes.Add($Attribute)
        }

        $Runtime = [System.Management.Automation.RuntimeDefinedParameter]::new($Source.Name, $Source.ParameterType, $Attributes)
        $Dictionary.Add($Source.Name, $Runtime)
    }

    return $Dictionary
}
