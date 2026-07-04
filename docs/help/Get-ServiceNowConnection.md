---
external help file: ServiceNow.API-help.xml
Module Name: ServiceNow.API
online version: https://github.com/deanlongstaff/ServiceNow.API
schema: 2.0.0
---

# Get-ServiceNowConnection

## SYNOPSIS
Returns one or all current ServiceNow connection contexts.

## SYNTAX

### Default (Default)
```
Get-ServiceNowConnection [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### Instance
```
Get-ServiceNowConnection [[-Instance] <String>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### All
```
Get-ServiceNowConnection [-All] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Returns a summary of a connection established by Connect-ServiceNow, including the instance,
base URL and authentication type.
Secrets are never returned: passwords and tokens are omitted,
and only the connected user name is shown.

With no parameters the current default connection is returned (or $null when none).
Use
-Instance to return a specific connection, or -All to list every connected instance.
The
IsDefault property indicates which connection is used when a cmdlet is called without -Instance
or -Connection.

## EXAMPLES

### EXAMPLE 1
```
Get-ServiceNowConnection
```

Return the current default connection.

### EXAMPLE 2
```
Get-ServiceNowConnection -All
```

List every connected instance.

## PARAMETERS

### -All
Return a summary for every connected instance.

```yaml
Type: SwitchParameter
Parameter Sets: All
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Instance
The name of a connected instance to return.

```yaml
Type: String
Parameter Sets: Instance
Aliases:

Required: False
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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Management.Automation.PSCustomObject, or $null when not connected.
## NOTES

## RELATED LINKS

[https://github.com/deanlongstaff/ServiceNow.API](https://github.com/deanlongstaff/ServiceNow.API)

