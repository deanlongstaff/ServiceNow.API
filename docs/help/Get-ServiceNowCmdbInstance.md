---
external help file: ServiceNow.API-help.xml
Module Name: ServiceNow.API
online version: https://github.com/deanlongstaff/ServiceNow.API
schema: 2.0.0
---

# Get-ServiceNowCmdbInstance

## SYNOPSIS
Retrieves configuration items through the CMDB Instance API.

## SYNTAX

### List (Default)
```
Get-ServiceNowCmdbInstance [-Class] <String> [-Query <String>] [-Filter <Object[]>] [-Limit <Int32>]
 [-Offset <Int32>] [-Instance <String>] [-Connection <Hashtable>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

### Single
```
Get-ServiceNowCmdbInstance [-Class] <String> -Sys_ID <String> [-Instance <String>] [-Connection <Hashtable>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Uses the class-aware CMDB Instance API rather than the raw Table API.
With -Sys_ID it returns a
single configuration item including its attributes and its inbound and outbound relationships;
otherwise it lists items of the given class, optionally filtered by a query.
This respects the
CMDB class model, so it is the recommended way to read CMDB data.

## EXAMPLES

### EXAMPLE 1
```
Get-ServiceNowCmdbInstance -Class cmdb_ci_linux_server -Sys_ID $sysId
```

Get a single Linux server CI with its relationships.

### EXAMPLE 2
```
Get-ServiceNowCmdbInstance -Class cmdb_ci_service -Query 'operational_status=1' -Limit 50
```

List operational business services.

## PARAMETERS

### -Class
The CMDB class (table) to query, for example 'cmdb_ci_linux_server'.

```yaml
Type: String
Parameter Sets: (All)
Aliases: sys_class_name

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

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

### -Filter
A structured filter turned into an encoded query by New-ServiceNowQuery.

```yaml
Type: Object[]
Parameter Sets: List
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
The maximum number of items to return when listing.

```yaml
Type: Int32
Parameter Sets: List
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Offset
The starting offset (number of items to skip) when listing.

```yaml
Type: Int32
Parameter Sets: List
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
A raw encoded query to filter the listed items.

```yaml
Type: String
Parameter Sets: List
Aliases: FilterString

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Sys_ID
The sys_id of a single configuration item to retrieve, with its relationships.

```yaml
Type: String
Parameter Sets: Single
Aliases: SysId, Id

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### The configuration item(s), including relationships for a single item.
## NOTES

## RELATED LINKS

[https://github.com/deanlongstaff/ServiceNow.API](https://github.com/deanlongstaff/ServiceNow.API)

