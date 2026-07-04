---
external help file: ServiceNow.API-help.xml
Module Name: ServiceNow.API
online version: https://github.com/deanlongstaff/ServiceNow.API
schema: 2.0.0
---

# Get-ServiceNowRecord

## SYNOPSIS
Retrieves records from any ServiceNow table.

## SYNTAX

```
Get-ServiceNowRecord [-Table] <String> [[-Sys_ID] <String>] [-Query <String>] [-Filter <Object[]>]
 [-Sort <Object[]>] [-Fields <String[]>] [-DisplayValue <String>] [-ExcludeReferenceLinks] [-Offset <Int32>]
 [-Limit <Int32>] [-RestrictDomain] [-SysParmView <String>] [-Instance <String>] [-Connection <Hashtable>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Queries the ServiceNow Table API and returns matching records.
Retrieve a single record by
sys_id, or filter a table using either a structured -Filter (see New-ServiceNowQuery), a raw
encoded -Query copied from the ServiceNow list view, or both.
Results are paginated
automatically; use -Limit to cap the number of records returned.

## EXAMPLES

### EXAMPLE 1
```
Get-ServiceNowRecord -Table incident -Sys_ID '46b66a40a9fe198101f243dfbc79033d'
```

Get a single incident by sys_id.

### EXAMPLE 2
```
Get-ServiceNowRecord -Table incident -Filter @('active', '-eq', 'true'), 'and', @('priority', '-le', '2') -Sort @('opened_at', 'desc') -Fields number, short_description
```

Get active priority 1-2 incidents, newest first, returning two fields.

### EXAMPLE 3
```
Get-ServiceNowRecord -Table sys_user -Query 'active=true' -Limit 100
```

Get the first 100 active users using a raw encoded query.

## PARAMETERS

### -Connection
An explicit connection object, overriding the connected session.

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DisplayValue
Return the display value, the underlying value, or both: 'true', 'false' or 'all'.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExcludeReferenceLinks
Remove the link objects from reference fields, returning just the value.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Fields
The fields to return.
Fewer fields means smaller, faster responses.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: Property, Properties

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Filter
A structured filter turned into an encoded query by New-ServiceNowQuery.
Conditions are arrays
of @(field, operator, value) combined with 'and', 'or' and 'group'.

```yaml
Type: Object[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Instance
The name of a connected instance to target, instead of the default connection.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Limit
The maximum number of records to return across all pages.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Offset
The starting offset (number of records to skip).

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 0
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

### -Query
A raw encoded query string, as copied from the ServiceNow list view ('Copy query'), for example
'active=true^priority=1'.

```yaml
Type: String
Parameter Sets: (All)
Aliases: FilterString

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RestrictDomain
Restrict results to the caller's domains (sends sysparm_query_no_domain=false).
Requires the
appropriate role on the instance.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Sort
One or more sort pairs, each @(field, 'asc'|'desc').

```yaml
Type: Object[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Sys_ID
Retrieve a single record directly by its sys_id.

```yaml
Type: String
Parameter Sets: (All)
Aliases: SysId, Id

Required: False
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -SysParmView
The UI view whose fields should be returned: 'desktop', 'mobile' or 'both'.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Table
The table to query, by name (for example 'incident', 'sys_user', 'cmdb_ci').

```yaml
Type: String
Parameter Sets: (All)
Aliases: sys_class_name

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### The matching record objects.
## NOTES

## RELATED LINKS

[https://github.com/deanlongstaff/ServiceNow.API](https://github.com/deanlongstaff/ServiceNow.API)

