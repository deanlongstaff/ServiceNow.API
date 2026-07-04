function ConvertTo-ServiceNowInstanceName {
    <#
        .SYNOPSIS
        Normalises a ServiceNow instance reference to a canonical name and base URL.

        .DESCRIPTION
        Internal helper shared by Connect-ServiceNow and Resolve-ServiceNowConnection so that a stored
        connection and a later -Instance lookup normalise the same way. Accepts a short instance name
        ('dev12345'), a hostname ('dev12345.service-now.com') or a full URL, and returns the canonical
        (lower-cased) instance name used as the registry key together with the instance base URL.

        .PARAMETER Instance
        The instance name, hostname or URL to normalise.

        .OUTPUTS
        System.Management.Automation.PSCustomObject with Name and BaseUrl.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Instance
    )

    $HostName = $Instance.Trim() -replace '^https?://', ''
    $HostName = ($HostName.TrimEnd('/') -split '/')[0]
    if ($HostName -notmatch '\.') {
        $HostName = "$HostName.service-now.com"
    }
    $HostName = $HostName.ToLower()
    $Name = ($HostName -split '\.')[0]

    return [pscustomobject]@{
        Name    = $Name
        BaseUrl = "https://$HostName"
    }
}
