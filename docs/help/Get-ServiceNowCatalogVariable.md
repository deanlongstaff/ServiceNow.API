---
external help file: ServiceNow.API-help.xml
Module Name: ServiceNow.API
online version: https://github.com/deanlongstaff/ServiceNow.API
schema: 2.0.0
---

# Get-ServiceNowCatalogVariable

## SYNOPSIS
Retrieves the catalog variable values submitted on a requested item.

## SYNTAX

```
Get-ServiceNowCatalogVariable [-RequestedItemId] <String> [-Instance <String>] [-Connection <Hashtable>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Returns the variables (the answers a user gave on the catalog form) for a requested item
(RITM).
It reads the sc_item_option_mtom join and dot-walks to each variable's name, question
and value, returning a clean object per variable.
Requested item objects from
Get-ServiceNowRequestedItem can be piped straight in.

## EXAMPLES

### EXAMPLE 1
```
Get-ServiceNowCatalogVariable -RequestedItemId $ritmSysId
```

Get the variable values for a requested item.

### EXAMPLE 2
```
Get-ServiceNowRequestedItem -Number 'RITM0010001' | Get-ServiceNowCatalogVariable
```

Get the variables for a RITM by piping it in.

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

### -RequestedItemId
The sys_id of the requested item (RITM) whose variables you want.

```yaml
Type: String
Parameter Sets: (All)
Aliases: SysId, Id, request_item

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

### One object per variable, with Name, Question and Value.
## NOTES

## RELATED LINKS

[https://github.com/deanlongstaff/ServiceNow.API](https://github.com/deanlongstaff/ServiceNow.API)

