function Remove-ServiceNowAttachment {
    <#
        .SYNOPSIS
        Deletes an attachment from ServiceNow.

        .DESCRIPTION
        Deletes an attachment by its sys_id using the Attachment API. Attachment metadata objects from
        Get-ServiceNowAttachment can be piped in. This is destructive and prompts for confirmation by
        default.

        .PARAMETER AttachmentId
        The sys_id of the attachment to delete.

        .PARAMETER Instance
        The name of a connected instance to target, instead of the default connection.

        .PARAMETER Connection
        An explicit connection object, overriding the connected session.

        .EXAMPLE
        Remove-ServiceNowAttachment -AttachmentId $attId

        Delete a single attachment.

        .EXAMPLE
        Get-ServiceNowAttachment -Table incident -Sys_ID $sysId | Remove-ServiceNowAttachment -Confirm:$false

        Delete every attachment on a record without prompting.

        .OUTPUTS
        None.

        .LINK
        https://github.com/deanlongstaff/ServiceNow.API
    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('sys_id', 'SysId')]
        [string]$AttachmentId,

        [Parameter()]
        [string]$Instance,

        [Parameter()]
        [hashtable]$Connection
    )

    process {
        $ConnectionParams = @{}
        if ($PSBoundParameters.ContainsKey('Connection')) { $ConnectionParams['Connection'] = $Connection }
        if ($PSBoundParameters.ContainsKey('Instance')) { $ConnectionParams['Instance'] = $Instance }

        if ($PSCmdlet.ShouldProcess($AttachmentId, 'Delete ServiceNow attachment')) {
            $null = Invoke-ServiceNowApi -Method 'DELETE' -Path "api/now/attachment/$AttachmentId" @ConnectionParams
        }
    }
}
