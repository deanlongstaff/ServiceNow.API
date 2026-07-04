function Add-ServiceNowAttachment {
    <#
        .SYNOPSIS
        Uploads a file and attaches it to a ServiceNow record.

        .DESCRIPTION
        Attaches one or more files to an existing record using the Attachment API. The content type is
        detected from the file extension by default and can be overridden. Records can be piped in from
        Get-ServiceNowRecord.

        .PARAMETER Table
        The table containing the target record.

        .PARAMETER Sys_ID
        The sys_id of the record to attach the file to.

        .PARAMETER Path
        One or more paths to the files to upload.

        .PARAMETER ContentType
        The content (MIME) type. Detected from the file extension when omitted.

        .PARAMETER FileName
        Override the attachment's file name. Only valid with a single file.

        .PARAMETER PassThru
        Return the created attachment metadata.

        .PARAMETER Instance
        The name of a connected instance to target, instead of the default connection.

        .PARAMETER Connection
        An explicit connection object, overriding the connected session.

        .EXAMPLE
        Add-ServiceNowAttachment -Table incident -Sys_ID $sysId -Path .\screenshot.png

        Attach a screenshot to an incident.

        .OUTPUTS
        None by default, or the attachment metadata when -PassThru is used.

        .LINK
        https://github.com/deanlongstaff/ServiceNow.API
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('sys_class_name')]
        [string]$Table,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('SysId', 'Id')]
        [string]$Sys_ID,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('FullName')]
        [string[]]$Path,

        [Parameter()]
        [string]$ContentType,

        [Parameter()]
        [string]$FileName,

        [Parameter()]
        [switch]$PassThru,

        [Parameter()]
        [string]$Instance,

        [Parameter()]
        [hashtable]$Connection
    )

    begin {
        $MimeTypes = @{
            '.txt'  = 'text/plain'
            '.csv'  = 'text/csv'
            '.json' = 'application/json'
            '.xml'  = 'application/xml'
            '.pdf'  = 'application/pdf'
            '.png'  = 'image/png'
            '.jpg'  = 'image/jpeg'
            '.jpeg' = 'image/jpeg'
            '.gif'  = 'image/gif'
            '.zip'  = 'application/zip'
            '.doc'  = 'application/msword'
            '.docx' = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
            '.xls'  = 'application/vnd.ms-excel'
            '.xlsx' = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
        }
    }

    process {
        $ConnectionParams = @{}
        if ($PSBoundParameters.ContainsKey('Connection')) { $ConnectionParams['Connection'] = $Connection }
        if ($PSBoundParameters.ContainsKey('Instance')) { $ConnectionParams['Instance'] = $Instance }

        if ($FileName -and $Path.Count -gt 1) {
            throw '-FileName can only be used when uploading a single file.'
        }

        foreach ($SinglePath in $Path) {
            $Resolved = Resolve-Path -Path $SinglePath -ErrorAction Stop
            $Item = Get-Item -Path $Resolved -ErrorAction Stop

            $ThisName = if ($FileName) { $FileName } else { $Item.Name }
            $ThisType = if ($ContentType) {
                $ContentType
            }
            elseif ($MimeTypes.ContainsKey($Item.Extension.ToLower())) {
                $MimeTypes[$Item.Extension.ToLower()]
            }
            else {
                'application/octet-stream'
            }

            $UploadQuery = @{
                table_name    = $Table
                table_sys_id  = $Sys_ID
                file_name     = $ThisName
            }

            if ($PSCmdlet.ShouldProcess("$Table/$Sys_ID", "Attach file '$ThisName'")) {
                $Response = Invoke-ServiceNowApi -Method 'POST' -Path 'api/now/attachment/file' -Query $UploadQuery -InFile $Item.FullName -ContentType $ThisType @ConnectionParams
                if ($PassThru) { $Response.result }
            }
        }
    }
}
