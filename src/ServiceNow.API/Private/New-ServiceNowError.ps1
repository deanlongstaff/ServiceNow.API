function New-ServiceNowError {
    <#
        .SYNOPSIS
        Builds a descriptive terminating error record for a failed ServiceNow request.

        .DESCRIPTION
        Internal helper. Produces an ErrorRecord whose message includes the HTTP method, URI, status
        code and parsed ServiceNow error message, and whose exception carries the status code under
        Data['ServiceNowStatusCode'] so callers can branch on it (for example, treating 404 as "not
        found").

        .PARAMETER Method
        The HTTP method that failed.

        .PARAMETER Uri
        The request URI that failed.

        .PARAMETER Detail
        The parsed response detail from Get-ServiceNowResponseDetail.

        .PARAMETER InnerException
        The original exception, preserved as the inner exception.

        .OUTPUTS
        System.Management.Automation.ErrorRecord.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Builds an in-memory error record; changes no state.')]
    [CmdletBinding()]
    [OutputType([System.Management.Automation.ErrorRecord])]
    param(
        [Parameter(Mandatory = $true)][string]$Method,
        [Parameter(Mandatory = $true)][string]$Uri,
        [Parameter(Mandatory = $true)][pscustomobject]$Detail,
        [Exception]$InnerException
    )

    $StatusText = if ($Detail.StatusCode -gt 0) { " (HTTP $($Detail.StatusCode))" } else { '' }
    $Message = "ServiceNow request '$Method $Uri' failed${StatusText}: $($Detail.Message)"

    $Exception = [System.Exception]::new($Message, $InnerException)
    [void]$Exception.Data.Add('ServiceNowStatusCode', $Detail.StatusCode)

    return [System.Management.Automation.ErrorRecord]::new(
        $Exception,
        'ServiceNowApiError',
        [System.Management.Automation.ErrorCategory]::InvalidOperation,
        $Uri
    )
}
