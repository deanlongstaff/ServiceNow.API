---
external help file: ServiceNow.API-help.xml
Module Name: ServiceNow.API
online version: https://github.com/deanlongstaff/ServiceNow.API
schema: 2.0.0
---

# Get-ServiceNowCatalogItem

## SYNOPSIS
Retrieves items from the ServiceNow Service Catalog.

## SYNTAX

### List (Default)
```
Get-ServiceNowCatalogItem [-Query <String>] [-Category <String>] [-CatalogId <String>] [-Limit <Int32>]
 [-Offset <Int32>] [-Instance <String>] [-Connection <Hashtable>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

### Single
```
Get-ServiceNowCatalogItem [-Sys_ID] <String> [-Instance <String>] [-Connection <Hashtable>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Uses the Service Catalog API to list or search catalog items, or to get a single item (including
its variables) by sys_id.
Filter by a free-text search, a category, or a specific catalog.

## EXAMPLES

### EXAMPLE 1
```
Get-ServiceNowCatalogItem -Query 'laptop'
```

Search the catalog for items matching 'laptop'.

### EXAMPLE 2
```
Get-ServiceNowCatalogItem -Sys_ID $itemSysId
```

Get a single catalog item and its variables.

## PARAMETERS

### -CatalogId
Limit results to a specific catalog sys_id.

```yaml
Type: String
Parameter Sets: List
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Category
Limit results to a catalog category sys_id.

```yaml
Type: String
Parameter Sets: List
Aliases:

Required: False
Position: Named
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
The maximum number of items to return.

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
The starting offset (number of items to skip).

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
A free-text search across catalog items (sysparm_text).

```yaml
Type: String
Parameter Sets: List
Aliases: Text, Search

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Sys_ID
The sys_id of a single catalog item to retrieve, including its variable definitions.

```yaml
Type: String
Parameter Sets: Single
Aliases: SysId, Id

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

### Catalog item object(s).
## NOTES

## RELATED LINKS

[https://github.com/deanlongstaff/ServiceNow.API](https://github.com/deanlongstaff/ServiceNow.API)

