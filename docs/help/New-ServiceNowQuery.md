---
external help file: ServiceNow.API-help.xml
Module Name: ServiceNow.API
online version: https://github.com/deanlongstaff/ServiceNow.API
schema: 2.0.0
---

# New-ServiceNowQuery

## SYNOPSIS
Builds a ServiceNow encoded query string from a filter and sort specification.

## SYNTAX

```
New-ServiceNowQuery [[-Filter] <Object[]>] [[-Sort] <Object[]>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
Turns a PowerShell-friendly filter into the encoded query string that ServiceNow's
sysparm_query expects.
Comparison operators mimic PowerShell (-eq, -like, -gt and so on), and
conditions are combined with the 'and', 'or' and 'group' joins.
Sorting is expressed as one or
more field/direction pairs.

A filter is an array whose elements are either a condition (an array of
@(field, operator, value)) or a join string ('and', 'or' or 'group').
A single condition may be
supplied on its own.

Supported operators: -eq, -ne, -lt, -le, -gt, -ge, -like, -notlike, -startswith, -endswith,
-in, -notin, -between (two values), -isempty, -isnotempty, -isanything, -on, -noton.

## EXAMPLES

### EXAMPLE 1
```
New-ServiceNowQuery -Filter @('active', '-eq', 'true')
```

Produces 'active=true'.

### EXAMPLE 2
```
New-ServiceNowQuery -Filter @('state', '-eq', '1'), 'or', @('short_description', '-like', 'network') -Sort @('opened_at', 'desc')
```

Produces 'state=1^ORshort_descriptionLIKEnetwork^ORDERBYDESCopened_at'.

### EXAMPLE 3
```
New-ServiceNowQuery -Filter @('sys_created_on', '-between', (Get-Date).AddDays(-7), (Get-Date))
```

Produces a BETWEEN query across the two dates.

## PARAMETERS

### -Filter
The filter specification.
See the description and examples.

```yaml
Type: Object[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProgressAction
{{ Fill ProgressAction Description }}

```yaml
Type: ActionPreference
Parameter Sets: (All)
Aliases: proga

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Sort
One or more sort pairs, each @(field, 'asc'|'desc').
A single field name sorts ascending.

```yaml
Type: Object[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.String. The encoded query.
## NOTES

## RELATED LINKS

[https://github.com/deanlongstaff/ServiceNow.API](https://github.com/deanlongstaff/ServiceNow.API)

