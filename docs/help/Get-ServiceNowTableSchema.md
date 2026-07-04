---
external help file: ServiceNow.API-help.xml
Module Name: ServiceNow.API
online version: https://github.com/deanlongstaff/ServiceNow.API
schema: 2.0.0
---

# Get-ServiceNowTableSchema

## SYNOPSIS
Describes the columns of a ServiceNow table.

## SYNTAX

```
Get-ServiceNowTableSchema [-Table] <String> [-Instance <String>] [-Connection <Hashtable>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Returns the field (column) definitions for a table by reading the sys_dictionary table.
This is
useful for discovering the columns defined on a table, their labels, types, whether they are
mandatory or read-only, and which table a reference field points to.

Only the columns defined directly on the specified table are returned.
To see fields a table
inherits, describe its parent table as well (for example, 'incident' extends 'task').

## EXAMPLES

### EXAMPLE 1
```
Get-ServiceNowTableSchema -Table incident
```

List the columns on the incident table.

### EXAMPLE 2
```
Get-ServiceNowTableSchema -Table incident | Where-Object Mandatory -eq 'true'
```

Find the mandatory fields on the incident table.

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

### -Table
The table to describe, for example 'incident'.

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

### Column definition objects (Element, Label, Type, Reference, Mandatory, MaxLength, Active).
## NOTES

## RELATED LINKS

[https://github.com/deanlongstaff/ServiceNow.API](https://github.com/deanlongstaff/ServiceNow.API)

