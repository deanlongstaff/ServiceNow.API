---
external help file: ServiceNow.API-help.xml
Module Name: ServiceNow.API
online version: https://github.com/deanlongstaff/ServiceNow.API
schema: 2.0.0
---

# Get-ServiceNowJournalEntry

## SYNOPSIS
Retrieves the comments and work notes for a record.

## SYNTAX

```
Get-ServiceNowJournalEntry [-Sys_ID] <String> [-Type <String>] [-Limit <Int32>] [-Instance <String>]
 [-Connection <Hashtable>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Reads journal entries (comments and work notes) for a record from the sys_journal_field table,
newest first.
Use -Type to return only comments or only work notes.
Each entry includes the
text, the field it came from, and who added it and when.

## EXAMPLES

### EXAMPLE 1
```
Get-ServiceNowJournalEntry -Sys_ID $incidentSysId
```

Get all comments and work notes for an incident.

### EXAMPLE 2
```
Get-ServiceNowIncident -Number 'INC0010023' | Get-ServiceNowJournalEntry -Type work_notes
```

Get just the work notes for an incident.

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

### -Limit
The maximum number of entries to return.

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

### -Sys_ID
The sys_id of the record whose journal entries you want.

```yaml
Type: String
Parameter Sets: (All)
Aliases: SysId, Id

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Type
Which entries to return: 'comments', 'work_notes' or 'all' (the default).

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: All
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### Journal entry records (element, value, sys_created_on, sys_created_by).
## NOTES

## RELATED LINKS

[https://github.com/deanlongstaff/ServiceNow.API](https://github.com/deanlongstaff/ServiceNow.API)

