---
external help file: ServiceNow.API-help.xml
Module Name: ServiceNow.API
online version: https://github.com/deanlongstaff/ServiceNow.API
schema: 2.0.0
---

# Get-ServiceNowAttachment

## SYNOPSIS
Retrieves attachment metadata from ServiceNow.

## SYNTAX

### Record (Default)
```
Get-ServiceNowAttachment -Table <String> -Sys_ID <String> [-FileName <String>] [-Limit <Int32>]
 [-Offset <Int32>] [-Instance <String>] [-Connection <Hashtable>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

### Attachment
```
Get-ServiceNowAttachment -AttachmentId <String> [-Instance <String>] [-Connection <Hashtable>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### Query
```
Get-ServiceNowAttachment -Query <String> [-Limit <Int32>] [-Offset <Int32>] [-Instance <String>]
 [-Connection <Hashtable>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Returns attachment metadata (sys_id, file name, content type, size and links) from the
Attachment API.
List the attachments on a specific record by providing -Table and -Sys_ID, get
a single attachment record by its own -AttachmentId, or search across the attachments table with
a raw -Query.
Use Save-ServiceNowAttachment to download the file content.

## EXAMPLES

### EXAMPLE 1
```
Get-ServiceNowAttachment -Table incident -Sys_ID $incidentSysId
```

List all attachments on an incident.

### EXAMPLE 2
```
Get-ServiceNowAttachment -Query 'content_type=application/pdf' -Limit 50
```

Find PDF attachments across the instance.

## PARAMETERS

### -AttachmentId
The sys_id of a single attachment record to retrieve.

```yaml
Type: String
Parameter Sets: Attachment
Aliases:

Required: True
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

### -FileName
Filter by file name (a 'contains' match) when listing a record's attachments.

```yaml
Type: String
Parameter Sets: Record
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
The maximum number of attachment records to return.

```yaml
Type: Int32
Parameter Sets: Record, Query
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
Parameter Sets: Record, Query
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
A raw encoded query against the sys_attachment table.

```yaml
Type: String
Parameter Sets: Query
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Sys_ID
The sys_id of the record whose attachments you want to list.

```yaml
Type: String
Parameter Sets: Record
Aliases: SysId, Id

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Table
The table of the record whose attachments you want to list.

```yaml
Type: String
Parameter Sets: Record
Aliases: sys_class_name

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

### Attachment metadata objects.
## NOTES

## RELATED LINKS

[https://github.com/deanlongstaff/ServiceNow.API](https://github.com/deanlongstaff/ServiceNow.API)

