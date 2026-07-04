---
external help file: ServiceNow.API-help.xml
Module Name: ServiceNow.API
online version: https://github.com/deanlongstaff/ServiceNow.API
schema: 2.0.0
---

# Invoke-ServiceNowGraphQL

## SYNOPSIS
Runs a GraphQL query against ServiceNow.

## SYNTAX

```
Invoke-ServiceNowGraphQL [-Query] <String> [-Variables <Hashtable>] [-Instance <String>]
 [-Connection <Hashtable>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Sends a query to the ServiceNow GraphQL API, which can return fields from several related
tables in a single request.
Supply the query text and, optionally, a hashtable of variables.
The parsed 'data' portion of the response is returned; if the response contains GraphQL
errors, a warning is written.

## EXAMPLES

### EXAMPLE 1
```
$query = 'query { GlideRecord_Query { incident(queryConditions: "active=true", limit: 5) { _results { number { value } short_description { value } } } } }'
Invoke-ServiceNowGraphQL -Query $query
```

Retrieve fields from the incident table with GraphQL.

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

### -Query
The GraphQL query text.

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

### -Variables
A hashtable of variables referenced by the query.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### The parsed 'data' object from the GraphQL response.
## NOTES

## RELATED LINKS

[https://github.com/deanlongstaff/ServiceNow.API](https://github.com/deanlongstaff/ServiceNow.API)

