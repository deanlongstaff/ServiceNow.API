---
external help file: ServiceNow.API-help.xml
Module Name: ServiceNow.API
online version: https://github.com/deanlongstaff/ServiceNow.API
schema: 2.0.0
---

# New-ServiceNowRecord

## SYNOPSIS
Creates a new record in a ServiceNow table.

## SYNTAX

```
New-ServiceNowRecord [-Table] <String> [-InputData] <Hashtable> [-InputDisplayValue] [-PassThru]
 [-Instance <String>] [-Connection <Hashtable>] [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Creates a record on any table using the Table API.
Supply the field values as a hashtable.
The
newly created record can be returned with -PassThru.

## EXAMPLES

### EXAMPLE 1
```
New-ServiceNowRecord -Table incident -InputData @{ short_description = 'Laptop will not boot'; urgency = 2 } -PassThru
```

Create an incident and return it.

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

### -InputData
A hashtable of field names and values for the new record.

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases: Values, Properties

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -InputDisplayValue
Treat the supplied values as display values rather than raw values
(sends sysparm_input_display_value=true).

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

### -PassThru
Return the created record.

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

### -Table
The table to create the record in, for example 'incident'.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
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

### None by default, or the created record when -PassThru is used.
## NOTES

## RELATED LINKS

[https://github.com/deanlongstaff/ServiceNow.API](https://github.com/deanlongstaff/ServiceNow.API)

