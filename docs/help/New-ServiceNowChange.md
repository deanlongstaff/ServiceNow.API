---
external help file: ServiceNow.API-help.xml
Module Name: ServiceNow.API
online version: https://github.com/deanlongstaff/ServiceNow.API
schema: 2.0.0
---

# New-ServiceNowChange

## SYNOPSIS
Creates a change request through the Change Management API.

## SYNTAX

```
New-ServiceNowChange [[-Type] <String>] [[-Template] <String>] [[-InputData] <Hashtable>] [-PassThru]
 [[-Instance] <String>] [[-Connection] <Hashtable>] [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Creates a change through the dedicated Change Management API (sn_chg_rest), which applies the
change model and its defaults.
Use -Type to choose 'normal', 'standard' or 'emergency'.
A
standard change is created from a template, so -Template (the standard change template sys_id)
is required for that type.
Supply any additional field values with -InputData.

This is distinct from New-ServiceNowRecord/New-ServiceNowChangeRequest, which write directly to
the change_request table via the Table API.
Use this cmdlet when you want the Change Management
API's model handling (for example, creating a standard change from a template).

## EXAMPLES

### EXAMPLE 1
```
New-ServiceNowChange -Type normal -InputData @{ short_description = 'Upgrade firmware' } -PassThru
```

Create a normal change and return it.

### EXAMPLE 2
```
New-ServiceNowChange -Type standard -Template $templateSysId -PassThru
```

Create a standard change from a template.

## PARAMETERS

### -Connection
An explicit connection object, overriding the connected session.

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -InputData
A hashtable of additional field values for the change.

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases: Values, Properties

Required: False
Position: 3
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
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PassThru
Return the created change.

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

### -Template
The sys_id of the standard change template.
Required when -Type is 'standard'.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Type
The change type: 'normal' (default), 'standard' or 'emergency'.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: Normal
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### None by default, or the created change when -PassThru is used.
## NOTES

## RELATED LINKS

[https://github.com/deanlongstaff/ServiceNow.API](https://github.com/deanlongstaff/ServiceNow.API)

