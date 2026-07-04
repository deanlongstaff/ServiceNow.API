---
external help file: ServiceNow.API-help.xml
Module Name: ServiceNow.API
online version: https://github.com/deanlongstaff/ServiceNow.API
schema: 2.0.0
---

# Get-ServiceNowConfigurationItem

## SYNOPSIS
Retrieves configuration item (cmdb_ci) records.

## SYNTAX

```
Get-ServiceNowConfigurationItem [-ProgressAction <ActionPreference>] [-Sys_ID <String>] [-Query <String>]
 [-Filter <Object[]>] [-Sort <Object[]>] [-Fields <String[]>] [-DisplayValue <String>] [-ExcludeReferenceLinks]
 [-Offset <Int32>] [-Limit <Int32>] [-RestrictDomain] [-SysParmView <String>] [-Instance <String>]
 [-Connection <Hashtable>] [<CommonParameters>]
```

## DESCRIPTION
A convenience wrapper around Get-ServiceNowRecord for the 'cmdb_ci' table (the CMDB base
class).
It accepts all the same filtering, field selection, sorting, pagination and connection
parameters.
Query a more specific CMDB class by using Get-ServiceNowRecord with that table name.

## EXAMPLES

### EXAMPLE 1
```
Get-ServiceNowConfigurationItem -Query 'name=EXCHANGE01'
```

Get a configuration item by name.

### EXAMPLE 2
```
Get-ServiceNowConfigurationItem -Filter @('operational_status', '-eq', '1') -Fields name, sys_class_name
```

List operational configuration items with their class.

## PARAMETERS

### -Connection
{{ Fill Connection Description }}

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

### -DisplayValue
{{ Fill DisplayValue Description }}

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

### -ExcludeReferenceLinks
{{ Fill ExcludeReferenceLinks Description }}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Fields
{{ Fill Fields Description }}

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: Property, Properties

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Filter
{{ Fill Filter Description }}

```yaml
Type: Object[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Instance
{{ Fill Instance Description }}

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
{{ Fill Limit Description }}

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Offset
{{ Fill Offset Description }}

```yaml
Type: Int32
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
{{ Fill Query Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases: FilterString

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RestrictDomain
{{ Fill RestrictDomain Description }}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Sort
{{ Fill Sort Description }}

```yaml
Type: Object[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Sys_ID
{{ Fill Sys_ID Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases: SysId, Id

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -SysParmView
{{ Fill SysParmView Description }}

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### The matching configuration item record(s).
## NOTES

## RELATED LINKS

[https://github.com/deanlongstaff/ServiceNow.API](https://github.com/deanlongstaff/ServiceNow.API)

