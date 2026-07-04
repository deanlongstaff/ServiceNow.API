function New-ServiceNowQuery {
    <#
        .SYNOPSIS
        Builds a ServiceNow encoded query string from a filter and sort specification.

        .DESCRIPTION
        Turns a PowerShell-friendly filter into the encoded query string that ServiceNow's
        sysparm_query expects. Comparison operators mimic PowerShell (-eq, -like, -gt and so on), and
        conditions are combined with the 'and', 'or' and 'group' joins. Sorting is expressed as one or
        more field/direction pairs.

        A filter is an array whose elements are either a condition (an array of
        @(field, operator, value)) or a join string ('and', 'or' or 'group'). A single condition may be
        supplied on its own.

        Supported operators: -eq, -ne, -lt, -le, -gt, -ge, -like, -notlike, -startswith, -endswith,
        -in, -notin, -between (two values), -isempty, -isnotempty, -isanything, -on, -noton.

        .PARAMETER Filter
        The filter specification. See the description and examples.

        .PARAMETER Sort
        One or more sort pairs, each @(field, 'asc'|'desc'). A single field name sorts ascending.

        .EXAMPLE
        New-ServiceNowQuery -Filter @('active', '-eq', 'true')

        Produces 'active=true'.

        .EXAMPLE
        New-ServiceNowQuery -Filter @('state', '-eq', '1'), 'or', @('short_description', '-like', 'network') -Sort @('opened_at', 'desc')

        Produces 'state=1^ORshort_descriptionLIKEnetwork^ORDERBYDESCopened_at'.

        .EXAMPLE
        New-ServiceNowQuery -Filter @('sys_created_on', '-between', (Get-Date).AddDays(-7), (Get-Date))

        Produces a BETWEEN query across the two dates.

        .OUTPUTS
        System.String. The encoded query.

        .LINK
        https://github.com/deanlongstaff/ServiceNow.API
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Builds an encoded query string in memory; changes no state.')]
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Position = 0)]
        [object[]]$Filter,

        [Parameter(Position = 1)]
        [object[]]$Sort
    )

    $OperatorMap = @{
        '-eq'         = '='
        '-ne'         = '!='
        '-lt'         = '<'
        '-le'         = '<='
        '-gt'         = '>'
        '-ge'         = '>='
        '-like'       = 'LIKE'
        '-notlike'    = 'NOTLIKE'
        '-startswith' = 'STARTSWITH'
        '-endswith'   = 'ENDSWITH'
        '-in'         = 'IN'
        '-notin'      = 'NOTIN'
        '-between'    = 'BETWEEN'
        '-isempty'    = 'ISEMPTY'
        '-isnotempty' = 'ISNOTEMPTY'
        '-isanything' = 'ANYTHING'
        '-on'         = 'ON'
        '-noton'      = 'NOTON'
    }
    $JoinMap = @{
        'and'   = '^'
        '-and'  = '^'
        'or'    = '^OR'
        '-or'   = '^OR'
        'group' = '^NQ'
        '-group' = '^NQ'
    }
    $NoValueOperators = @('ISEMPTY', 'ISNOTEMPTY', 'ANYTHING')

    # -- Format a value: dates use ServiceNow's expected 'yyyy-MM-dd HH:mm:ss' form.
    function Format-Value {
        param($Value)
        if ($Value -is [datetime]) {
            return $Value.ToString('yyyy-MM-dd HH:mm:ss')
        }
        return [string]$Value
    }

    $Builder = [System.Text.StringBuilder]::new()

    if ($Filter -and $Filter.Count -gt 0) {
        # -- Normalise: a bare single condition (@('field','-eq','value')) becomes a one-element list.
        $Elements = $Filter
        if ($Filter[0] -isnot [array] -and $Filter[0] -isnot [string]) {
            throw "Invalid filter. Provide condition arrays like @('field','-eq','value') optionally separated by 'and'/'or'/'group'."
        }
        if ($Filter[0] -is [string] -and -not $JoinMap.ContainsKey([string]$Filter[0])) {
            # -- A single condition passed as a flat array, e.g. @('field','-eq','value').
            $Elements = , $Filter
        }

        foreach ($Element in $Elements) {
            if ($Element -is [string]) {
                $Key = $Element.ToLower()
                if (-not $JoinMap.ContainsKey($Key)) {
                    throw "Unknown join '$Element'. Use 'and', 'or' or 'group'."
                }
                [void]$Builder.Append($JoinMap[$Key])
                continue
            }

            $Condition = @($Element)
            if ($Condition.Count -lt 2) {
                throw "Invalid condition '$($Condition -join ',')'. Expected @(field, operator[, value])."
            }

            $Field = [string]$Condition[0]
            $OpName = [string]$Condition[1]
            if (-not $OperatorMap.ContainsKey($OpName.ToLower())) {
                throw "Unknown operator '$OpName'. See Get-Help New-ServiceNowQuery for supported operators."
            }
            $Op = $OperatorMap[$OpName.ToLower()]

            if ($Op -in $NoValueOperators) {
                [void]$Builder.Append(('{0}{1}' -f $Field, $Op))
            }
            elseif ($Op -eq 'BETWEEN') {
                if ($Condition.Count -lt 4) {
                    throw "The -between operator requires two values: @(field, '-between', start, end)."
                }
                $ValuePart = '{0}@{1}' -f (Format-Value $Condition[2]), (Format-Value $Condition[3])
                [void]$Builder.Append(('{0}BETWEEN{1}' -f $Field, $ValuePart))
            }
            else {
                if ($Condition.Count -lt 3) {
                    throw "The operator '$OpName' requires a value: @(field, operator, value)."
                }
                [void]$Builder.Append(('{0}{1}{2}' -f $Field, $Op, (Format-Value $Condition[2])))
            }
        }
    }

    if ($Sort -and $Sort.Count -gt 0) {
        # -- Normalise a single pair (@('field','desc')) into a one-element list.
        $SortPairs = $Sort
        if ($Sort[0] -is [string]) {
            $SortPairs = , $Sort
        }

        foreach ($Pair in $SortPairs) {
            $PairArray = @($Pair)
            $SortField = [string]$PairArray[0]
            $Direction = if ($PairArray.Count -ge 2) { [string]$PairArray[1] } else { 'asc' }
            if ($Direction -match '^(?i)desc') {
                [void]$Builder.Append(('^ORDERBYDESC{0}' -f $SortField))
            }
            else {
                [void]$Builder.Append(('^ORDERBY{0}' -f $SortField))
            }
        }
    }

    return $Builder.ToString()
}
