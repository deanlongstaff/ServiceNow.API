function Save-ServiceNowAttachment {
    <#
        .SYNOPSIS
        Downloads a ServiceNow attachment to disk.

        .DESCRIPTION
        Downloads the binary content of an attachment by its sys_id and writes it to a file. Attachment
        metadata objects from Get-ServiceNowAttachment can be piped straight in, so you can list and
        download in one pipeline.

        .PARAMETER AttachmentId
        The sys_id of the attachment to download.

        .PARAMETER FileName
        The file name to use. Taken from the piped attachment metadata when available.

        .PARAMETER Path
        The destination. A directory saves the file under its attachment name; a full file path saves to
        that exact path. Defaults to the current directory.

        .PARAMETER Force
        Overwrite the destination file if it already exists.

        .PARAMETER PassThru
        Return the downloaded file as a System.IO.FileInfo.

        .PARAMETER Instance
        The name of a connected instance to target, instead of the default connection.

        .PARAMETER Connection
        An explicit connection object, overriding the connected session.

        .EXAMPLE
        Save-ServiceNowAttachment -AttachmentId $attId -Path C:\Temp

        Download a single attachment into a folder.

        .EXAMPLE
        Get-ServiceNowAttachment -Table incident -Sys_ID $sysId | Save-ServiceNowAttachment -Path .\downloads

        Download every attachment on a record.

        .OUTPUTS
        None by default, or System.IO.FileInfo when -PassThru is used.

        .LINK
        https://github.com/deanlongstaff/ServiceNow.API
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([System.IO.FileInfo])]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('sys_id', 'SysId')]
        [string]$AttachmentId,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('file_name')]
        [string]$FileName,

        [Parameter()]
        [string]$Path = (Get-Location).Path,

        [Parameter()]
        [switch]$Force,

        [Parameter()]
        [switch]$PassThru,

        [Parameter()]
        [string]$Instance,

        [Parameter()]
        [hashtable]$Connection
    )

    process {
        $ConnectionParams = @{}
        if ($PSBoundParameters.ContainsKey('Connection')) { $ConnectionParams['Connection'] = $Connection }
        if ($PSBoundParameters.ContainsKey('Instance')) { $ConnectionParams['Instance'] = $Instance }

        # -- Decide the destination path: a directory uses the attachment file name.
        $IsDirectory = (Test-Path -Path $Path -PathType Container) -or $Path.EndsWith([System.IO.Path]::DirectorySeparatorChar) -or $Path.EndsWith('/')
        if ($IsDirectory) {
            $ThisName = $FileName
            if ([string]::IsNullOrWhiteSpace($ThisName)) {
                # -- Look up the file name from the attachment metadata.
                $Meta = Invoke-ServiceNowApi -Method 'GET' -Path "api/now/attachment/$AttachmentId" @ConnectionParams
                $ThisName = $Meta.result.file_name
            }
            if ([string]::IsNullOrWhiteSpace($ThisName)) { $ThisName = $AttachmentId }
            $Destination = Join-Path -Path $Path -ChildPath $ThisName
        }
        else {
            $Destination = $Path
        }

        if ((Test-Path -Path $Destination) -and -not $Force) {
            throw "File '$Destination' already exists. Use -Force to overwrite."
        }

        if ($PSCmdlet.ShouldProcess($Destination, "Download attachment '$AttachmentId'")) {
            Invoke-ServiceNowApi -Method 'GET' -Path "api/now/attachment/$AttachmentId/file" -OutFile $Destination @ConnectionParams
            if ($PassThru) { Get-Item -Path $Destination }
        }
    }
}
