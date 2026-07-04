function Get-ServiceNowResponseDetail {
    <#
        .SYNOPSIS
        Extracts HTTP status, error body and Retry-After from a failed request.

        .DESCRIPTION
        Internal helper that normalises error details across PowerShell editions. PowerShell 7 exposes
        the response body via ErrorDetails.Message, while Windows PowerShell 5.1 requires reading the
        response stream. The HTTP status code and any Retry-After header are also extracted where
        available so the request engine can make retry decisions and surface a useful message.

        .PARAMETER ErrorRecord
        The error record caught from Invoke-RestMethod or Invoke-WebRequest.

        .OUTPUTS
        System.Management.Automation.PSCustomObject with StatusCode, Body, Message and RetryAfterSeconds.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.ErrorRecord]$ErrorRecord
    )

    $StatusCode = 0
    $Body = $null
    $RetryAfterSeconds = $null

    $Response = $ErrorRecord.Exception.Response
    if ($Response) {
        try { $StatusCode = [int]$Response.StatusCode } catch { $StatusCode = 0 }

        # -- Retry-After may be seconds (delta) or an HTTP date.
        try {
            $RawHeaders = $Response.Headers
            if ($RawHeaders) {
                if ($RawHeaders['Retry-After']) {
                    $RetryAfterSeconds = [int]$RawHeaders['Retry-After']
                }
                elseif ($RawHeaders.RetryAfter -and $RawHeaders.RetryAfter.Delta) {
                    $RetryAfterSeconds = [int]$RawHeaders.RetryAfter.Delta.TotalSeconds
                }
            }
        }
        catch {
            $RetryAfterSeconds = $null
        }
    }

    # -- Response body: PS7 populates ErrorDetails.Message; PS 5.1 needs the response stream.
    if ($ErrorRecord.ErrorDetails -and $ErrorRecord.ErrorDetails.Message) {
        $Body = $ErrorRecord.ErrorDetails.Message
    }
    elseif ($Response -and ($Response | Get-Member -Name GetResponseStream -ErrorAction SilentlyContinue)) {
        try {
            $Stream = $Response.GetResponseStream()
            $Reader = [System.IO.StreamReader]::new($Stream)
            try { $Body = $Reader.ReadToEnd() } finally { $Reader.Dispose() }
        }
        catch {
            $Body = $null
        }
    }

    # -- Surface the ServiceNow error message/detail when the body is JSON.
    $Message = $ErrorRecord.Exception.Message
    if (-not [string]::IsNullOrWhiteSpace($Body)) {
        try {
            $Parsed = $Body | ConvertFrom-Json -ErrorAction Stop
            if ($Parsed.error) {
                $Parts = @()
                if ($Parsed.error.message) { $Parts += [string]$Parsed.error.message }
                if ($Parsed.error.detail) { $Parts += [string]$Parsed.error.detail }
                if ($Parts.Count -gt 0) { $Message = $Parts -join ' - ' }
            }
        }
        catch {
            # -- Not JSON; keep the exception message and raw body.
            Write-Debug 'ServiceNow error body is not JSON; using the raw message.'
        }
    }

    return [pscustomobject]@{
        StatusCode        = $StatusCode
        Body              = $Body
        Message           = $Message
        RetryAfterSeconds = $RetryAfterSeconds
    }
}
