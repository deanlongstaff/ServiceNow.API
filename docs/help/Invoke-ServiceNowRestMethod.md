---
external help file: ServiceNow.API-help.xml
Module Name: ServiceNow.API
online version: https://github.com/deanlongstaff/ServiceNow.API
schema: 2.0.0
---

# Invoke-ServiceNowRestMethod

## SYNOPSIS
Sends an arbitrary authenticated request to the ServiceNow REST API.

## SYNTAX

```
Invoke-ServiceNowRestMethod [-Method <String>] [-Path] <String> [-Query <Hashtable>] [-Body <Object>]
 [-ContentType <String>] [-Headers <Hashtable>] [-Raw] [-OutFile <String>] [-Instance <String>]
 [-Connection <Hashtable>] [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
A general-purpose escape hatch for any ServiceNow REST endpoint not covered by a dedicated
cmdlet.
It reuses the module's authentication, token refresh, rate-limit handling and
transient-error retries, so you only supply the method, path and body.

## EXAMPLES

### EXAMPLE 1
```
Invoke-ServiceNowRestMethod -Path 'api/now/table/incident' -Query @{ sysparm_limit = 1 }
```

Call the Table API directly.

### EXAMPLE 2
```
Invoke-ServiceNowRestMethod -Method POST -Path 'api/sn_sc/servicecatalog/cart/checkout'
```

Post to an endpoint with no dedicated cmdlet.

## PARAMETERS

### -Body
Optional request body.
A string is sent verbatim; any other object is serialised to JSON.

```yaml
Type: Object
Parameter Sets: (All)
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

### -ContentType
The request content type.
Defaults to 'application/json'.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Application/json
Accept pipeline input: False
Accept wildcard characters: False
```

### -Headers
Optional additional request headers.

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

### -Method
The HTTP method.
Defaults to GET.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: GET
Accept pipeline input: False
Accept wildcard characters: False
```

### -OutFile
Write the response body to this path instead of returning it.

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

### -Path
The endpoint path relative to the instance base URL (for example 'api/now/table/incident'), or
an absolute instance URL.

```yaml
Type: String
Parameter Sets: (All)
Aliases: Uri, UriLeaf

Required: True
Position: 1
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
Optional hashtable of query-string parameters, URL-encoded automatically.

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

### -Raw
Return the raw response bytes instead of parsed JSON.

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

### The parsed response, raw bytes with -Raw, or nothing with -OutFile.
## NOTES

## RELATED LINKS

[https://github.com/deanlongstaff/ServiceNow.API](https://github.com/deanlongstaff/ServiceNow.API)

