---
external help file: ServiceNow.API-help.xml
Module Name: ServiceNow.API
online version: https://github.com/deanlongstaff/ServiceNow.API
schema: 2.0.0
---

# Submit-ServiceNowCatalogCart

## SYNOPSIS
Submits the current Service Catalog cart as an order.

## SYNTAX

```
Submit-ServiceNowCatalogCart [[-Instance] <String>] [[-Connection] <Hashtable>]
 [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Places an order for everything in the current user's cart using the Service Catalog API's
submit_order endpoint.
Returns the resulting request details, including the request number.
Build the cart first with Add-ServiceNowCatalogCartItem.

## EXAMPLES

### EXAMPLE 1
```
Submit-ServiceNowCatalogCart
```

Order everything currently in the cart.

## PARAMETERS

### -Connection
An explicit connection object, overriding the connected session.

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
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

### The order result, including the request number.
## NOTES

## RELATED LINKS

[https://github.com/deanlongstaff/ServiceNow.API](https://github.com/deanlongstaff/ServiceNow.API)

