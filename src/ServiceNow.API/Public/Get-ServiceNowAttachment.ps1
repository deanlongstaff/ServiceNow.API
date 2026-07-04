function Get-ServiceNowAttachment {
    <#
        .SYNOPSIS
        Retrieves attachment metadata from ServiceNow.

        .DESCRIPTION
        Returns attachment metadata (sys_id, file name, content type, size and links) from the
        Attachment API. List the attachments on a specific record by providing -Table and -Sys_ID, get
        a single attachment record by its own -AttachmentId, or search across the attachments table with
        a raw -Query. Use Save-ServiceNowAttachment to download the file content.

        .PARAMETER Table
        The table of the record whose attachments you want to list.

        .PARAMETER Sys_ID
        The sys_id of the record whose attachments you want to list.

        .PARAMETER AttachmentId
        The sys_id of a single attachment record to retrieve.

        .PARAMETER Query
        A raw encoded query against the sys_attachment table.

        .PARAMETER FileName
        Filter by file name (a 'contains' match) when listing a record's attachments.

        .PARAMETER Limit
        The maximum number of attachment records to return.

        .PARAMETER Offset
        The starting offset (number of records to skip).

        .PARAMETER Instance
        The name of a connected instance to target, instead of the default connection.

        .PARAMETER Connection
        An explicit connection object, overriding the connected session.

        .EXAMPLE
        Get-ServiceNowAttachment -Table incident -Sys_ID $incidentSysId

        List all attachments on an incident.

        .EXAMPLE
        Get-ServiceNowAttachment -Query 'content_type=application/pdf' -Limit 50

        Find PDF attachments across the instance.

        .OUTPUTS
        Attachment metadata objects.

        .LINK
        https://github.com/deanlongstaff/ServiceNow.API
    #>
    [CmdletBinding(DefaultParameterSetName = 'Record')]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'Record', ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('sys_class_name')]
        [string]$Table,

        [Parameter(Mandatory = $true, ParameterSetName = 'Record', ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('SysId', 'Id')]
        [string]$Sys_ID,

        [Parameter(Mandatory = $true, ParameterSetName = 'Attachment')]
        [ValidateNotNullOrEmpty()]
        [string]$AttachmentId,

        [Parameter(Mandatory = $true, ParameterSetName = 'Query')]
        [ValidateNotNullOrEmpty()]
        [string]$Query,

        [Parameter(ParameterSetName = 'Record')]
        [string]$FileName,

        [Parameter(ParameterSetName = 'Record')]
        [Parameter(ParameterSetName = 'Query')]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$Limit,

        [Parameter(ParameterSetName = 'Record')]
        [Parameter(ParameterSetName = 'Query')]
        [ValidateRange(0, [int]::MaxValue)]
        [int]$Offset = 0,

        [Parameter()]
        [string]$Instance,

        [Parameter()]
        [hashtable]$Connection
    )

    process {
        $ConnectionParams = @{}
        if ($PSBoundParameters.ContainsKey('Connection')) { $ConnectionParams['Connection'] = $Connection }
        if ($PSBoundParameters.ContainsKey('Instance')) { $ConnectionParams['Instance'] = $Instance }

        if ($PSCmdlet.ParameterSetName -eq 'Attachment') {
            $Response = Invoke-ServiceNowApi -Method 'GET' -Path "api/now/attachment/$AttachmentId" @ConnectionParams
            return $Response.result
        }

        # -- Build the encoded query for the sys_attachment table.
        if ($PSCmdlet.ParameterSetName -eq 'Record') {
            $Conditions = "table_name=$Table^table_sys_id=$Sys_ID"
            if ($FileName) { $Conditions += "^file_nameLIKE$FileName" }
        }
        else {
            $Conditions = $Query
        }

        $PageSize = 1000
        if ($PSBoundParameters.ContainsKey('Limit') -and $Limit -lt $PageSize) { $PageSize = $Limit }
        $CurrentOffset = $Offset
        $Returned = 0

        while ($true) {
            $PageQuery = @{
                sysparm_query  = $Conditions
                sysparm_limit  = $PageSize
                sysparm_offset = $CurrentOffset
            }
            $Response = Invoke-ServiceNowApi -Method 'GET' -Path 'api/now/attachment' -Query $PageQuery @ConnectionParams
            $Page = @($Response.result)
            if ($Page.Count -eq 0) { break }

            foreach ($Record in $Page) {
                $Record
                $Returned++
                if ($PSBoundParameters.ContainsKey('Limit') -and $Returned -ge $Limit) { return }
            }

            if ($Page.Count -lt $PageSize) { break }
            $CurrentOffset += $PageSize
        }
    }
}
