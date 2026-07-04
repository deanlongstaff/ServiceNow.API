---
external help file: ServiceNow.API-help.xml
Module Name: ServiceNow.API
online version: https://github.com/deanlongstaff/ServiceNow.API
schema: 2.0.0
---

# Get-ServiceNowKnowledgeArticle

## SYNOPSIS
Retrieves Knowledge Base articles from ServiceNow.

## SYNTAX

### Search (Default)
```
Get-ServiceNowKnowledgeArticle [[-Query] <String>] [-KnowledgeBase <String[]>] [-Language <String>]
 [-Limit <Int32>] [-Offset <Int32>] [-Instance <String>] [-Connection <Hashtable>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### Single
```
Get-ServiceNowKnowledgeArticle [-ArticleId] <String> [-Instance <String>] [-Connection <Hashtable>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Uses the Knowledge Management API to search for Knowledge Base articles by text, or to retrieve
a single article by its number or sys_id (including the rendered article body).
Only articles
the connected user is permitted to view are returned.

## EXAMPLES

### EXAMPLE 1
```
Get-ServiceNowKnowledgeArticle -Query 'vpn setup'
```

Search the knowledge base for VPN setup articles.

### EXAMPLE 2
```
Get-ServiceNowKnowledgeArticle -ArticleId 'KB0010001'
```

Retrieve a single article and its content.

## PARAMETERS

### -ArticleId
The article number (for example 'KB0010001') or sys_id of a single article to retrieve.

```yaml
Type: String
Parameter Sets: Single
Aliases: SysId, Id, Number

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
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

### -KnowledgeBase
Limit the search to one or more knowledge base sys_ids.

```yaml
Type: String[]
Parameter Sets: Search
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Language
The language code for the results, for example 'en'.

```yaml
Type: String
Parameter Sets: Search
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Limit
The maximum number of articles to return.

```yaml
Type: Int32
Parameter Sets: Search
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Offset
The starting offset (number of articles to skip).

```yaml
Type: Int32
Parameter Sets: Search
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
A free-text search across knowledge articles.

```yaml
Type: String
Parameter Sets: Search
Aliases: Text, Search

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### Knowledge article object(s).
## NOTES

## RELATED LINKS

[https://github.com/deanlongstaff/ServiceNow.API](https://github.com/deanlongstaff/ServiceNow.API)

