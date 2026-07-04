function Export-ServiceNowRecord {
    <#
        .SYNOPSIS
        Exports table records to a file.

        .DESCRIPTION
        Exports records from a table to CSV, XML, PDF or Excel using ServiceNow's list export
        processor. The output format is chosen from the file extension of -Path. You can filter with
        -Filter or -Query, sort with -Sort, and choose columns with -Fields, just like
        Get-ServiceNowRecord. Export row limits are governed by the instance's export properties.

        .PARAMETER Table
        The table to export, for example 'incident'.

        .PARAMETER Query
        A raw encoded query to filter the exported rows.

        .PARAMETER Filter
        A structured filter turned into an encoded query by New-ServiceNowQuery.

        .PARAMETER Sort
        One or more sort pairs, each @(field, 'asc'|'desc').

        .PARAMETER Fields
        The columns to include in the export.

        .PARAMETER Path
        The output file path. The extension selects the format: .csv, .xml, .pdf, .xls or .xlsx.

        .PARAMETER PassThru
        Return the created file as a System.IO.FileInfo.

        .PARAMETER Instance
        The name of a connected instance to target, instead of the default connection.

        .PARAMETER Connection
        An explicit connection object, overriding the connected session.

        .EXAMPLE
        Export-ServiceNowRecord -Table incident -Filter @('active', '-eq', 'true') -Fields number, short_description -Path .\incidents.csv

        Export active incidents to CSV.

        .OUTPUTS
        None by default, or System.IO.FileInfo when -PassThru is used.

        .LINK
        https://github.com/deanlongstaff/ServiceNow.API
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([System.IO.FileInfo])]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$Table,

        [Parameter()]
        [Alias('FilterString')]
        [string]$Query,

        [Parameter()]
        [object[]]$Filter,

        [Parameter()]
        [object[]]$Sort,

        [Parameter()]
        [Alias('Property', 'Properties')]
        [string[]]$Fields,

        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [string]$Path,

        [Parameter()]
        [switch]$PassThru,

        [Parameter()]
        [string]$Instance,

        [Parameter()]
        [hashtable]$Connection
    )

    $ConnectionParams = @{}
    if ($PSBoundParameters.ContainsKey('Connection')) { $ConnectionParams['Connection'] = $Connection }
    if ($PSBoundParameters.ContainsKey('Instance')) { $ConnectionParams['Instance'] = $Instance }

    $Extension = [System.IO.Path]::GetExtension($Path).TrimStart('.').ToLower()
    $Format = switch ($Extension) {
        'csv' { 'CSV' }
        'xml' { 'XML' }
        'pdf' { 'PDF' }
        'xls' { 'EXCEL' }
        'xlsx' { 'EXCEL' }
        default { throw "Unsupported export extension '.$Extension'. Use .csv, .xml, .pdf, .xls or .xlsx." }
    }

    # -- Build the encoded query from -Filter/-Query and -Sort.
    $Encoded = ''
    if ($Filter) {
        $Encoded = New-ServiceNowQuery -Filter $Filter -Sort $Sort
    }
    elseif ($Query -or $Sort) {
        $Encoded = [string]$Query
        if ($Sort) { $Encoded += (New-ServiceNowQuery -Sort $Sort) }
        $Encoded = $Encoded.TrimStart('^')
    }

    # -- The list export processor takes the format as a bare query token, then sysparm_* parameters.
    $Segments = [System.Collections.Generic.List[string]]::new()
    $Segments.Add($Format)
    if (-not [string]::IsNullOrEmpty($Encoded)) { $Segments.Add("sysparm_query=$([uri]::EscapeDataString($Encoded))") }
    if ($Fields) { $Segments.Add("sysparm_fields=$([uri]::EscapeDataString(($Fields -join ',')))") }

    $RequestPath = '{0}_list.do?{1}' -f $Table, ($Segments -join '&')

    if ($PSCmdlet.ShouldProcess($Path, "Export $Table records ($Format)")) {
        Invoke-ServiceNowApi -Method 'GET' -Path $RequestPath -OutFile $Path -Headers @{ Accept = '*/*' } @ConnectionParams
        if ($PassThru) { Get-Item -Path $Path }
    }
}
