function New-ServiceNowRecord {
    <#
        .SYNOPSIS
        Creates a new record in a ServiceNow table.

        .DESCRIPTION
        Creates a record on any table using the Table API. Supply the field values as a hashtable. The
        newly created record can be returned with -PassThru.

        .PARAMETER Table
        The table to create the record in, for example 'incident'.

        .PARAMETER InputData
        A hashtable of field names and values for the new record.

        .PARAMETER InputDisplayValue
        Treat the supplied values as display values rather than raw values
        (sends sysparm_input_display_value=true).

        .PARAMETER PassThru
        Return the created record.

        .PARAMETER Instance
        The name of a connected instance to target, instead of the default connection.

        .PARAMETER Connection
        An explicit connection object, overriding the connected session.

        .EXAMPLE
        New-ServiceNowRecord -Table incident -InputData @{ short_description = 'Laptop will not boot'; urgency = 2 } -PassThru

        Create an incident and return it.

        .OUTPUTS
        None by default, or the created record when -PassThru is used.

        .LINK
        https://github.com/deanlongstaff/ServiceNow.API
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$Table,

        [Parameter(Mandatory = $true, Position = 1, ValueFromPipeline = $true)]
        [ValidateNotNull()]
        [Alias('Values', 'Properties')]
        [hashtable]$InputData,

        [Parameter()]
        [switch]$InputDisplayValue,

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

        $QueryParams = @{}
        if ($InputDisplayValue) { $QueryParams['sysparm_input_display_value'] = 'true' }

        if ($PSCmdlet.ShouldProcess($Table, 'Create ServiceNow record')) {
            $Response = Invoke-ServiceNowApi -Method 'POST' -Path "api/now/table/$Table" -Query $QueryParams -Body $InputData @ConnectionParams
            if ($PassThru) { return $Response.result }
        }
    }
}
