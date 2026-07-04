---
external help file: ServiceNow.API-help.xml
Module Name: ServiceNow.API
online version: https://github.com/deanlongstaff/ServiceNow.API
schema: 2.0.0
---

# Invoke-ServiceNowIdentifyReconcile

## SYNOPSIS
Creates or updates configuration items using the Identification and Reconciliation API.

## SYNTAX

```
Invoke-ServiceNowIdentifyReconcile [-InputData] <Hashtable> [-DataSource <String>] [-Instance <String>]
 [-Connection <Hashtable>] [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Sends a payload to the CMDB Identification and Reconciliation (IRE) API, which de-duplicates
against identification rules before inserting or updating configuration items and their
relationships.
This is the correct way to ingest CMDB data from an integration, avoiding
duplicate CIs.
Supply the payload as a hashtable with an 'items' array (and optionally
'relations').

## EXAMPLES

### EXAMPLE 1
```
$payload = @{
    items = @(
        @{
            className = 'cmdb_ci_linux_server'
            values    = @{ name = 'app-svr-07'; serial_number = 'SN-12345' }
        }
    )
}
Invoke-ServiceNowIdentifyReconcile -InputData $payload -DataSource 'MyIntegration'
```

Identify and reconcile a Linux server CI.

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

### -DataSource
An optional data source name recorded against the operation (sysparm_data_source).

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

### -InputData
The IRE payload.
A hashtable with an 'items' array describing the CIs to identify and reconcile.

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases: Payload, Items

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
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

### The reconciliation result, including the affected CI sys_ids.
## NOTES

## RELATED LINKS

[https://github.com/deanlongstaff/ServiceNow.API](https://github.com/deanlongstaff/ServiceNow.API)

