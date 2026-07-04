---
external help file: ServiceNow.API-help.xml
Module Name: ServiceNow.API
online version: https://github.com/deanlongstaff/ServiceNow.API
schema: 2.0.0
---

# Invoke-ServiceNowBatch

## SYNOPSIS
Executes multiple ServiceNow REST requests in a single Batch API call.

## SYNTAX

```
Invoke-ServiceNowBatch [-Request] <Hashtable[]> [-BatchRequestId <String>] [-Instance <String>]
 [-Connection <Hashtable>] [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Sends several REST requests together using the Batch API, reducing round trips and the impact of
rate limits.
Each request is a hashtable describing the Method, Url and optional Body and
Headers.
The response contains one result per request, with the (decoded) body and status code,
plus any requests the platform could not service.

## EXAMPLES

### EXAMPLE 1
```
$requests = @(
    @{ Id = 'a'; Method = 'GET'; Url = '/api/now/table/incident?sysparm_limit=1' }
    @{ Id = 'b'; Method = 'POST'; Url = '/api/now/table/incident'; Body = @{ short_description = 'Batch created' } }
)
Invoke-ServiceNowBatch -Request $requests
```

Run a read and a create together.

## PARAMETERS

### -BatchRequestId
An identifier for the overall batch.
Defaults to a new GUID.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: ([guid]::NewGuid().ToString())
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

### -Request
One or more request definitions.
Each is a hashtable with keys:
  - Method  : GET, POST, PATCH, PUT or DELETE (default GET)
  - Url     : the request path, for example '/api/now/table/incident?sysparm_limit=1'
  - Body    : optional; a string is sent verbatim, any other object is serialised to JSON
  - Headers : optional hashtable of extra headers
  - Id      : optional identifier echoed back in the response (auto-generated when omitted)

```yaml
Type: Hashtable[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
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

### One PSCustomObject per request, with Id, StatusCode, Body, Headers and ExecutionTime.
## NOTES

## RELATED LINKS

[https://github.com/deanlongstaff/ServiceNow.API](https://github.com/deanlongstaff/ServiceNow.API)

