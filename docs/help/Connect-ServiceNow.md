---
external help file: ServiceNow.API-help.xml
Module Name: ServiceNow.API
online version: https://github.com/deanlongstaff/ServiceNow.API
schema: 2.0.0
---

# Connect-ServiceNow

## SYNOPSIS
Establishes a ServiceNow connection for the current session.

## SYNTAX

### Basic (Default)
```
Connect-ServiceNow [-Instance] <String> -Credential <PSCredential> [-MaxRetry <Int32>]
 [-RetryDelaySeconds <Int32>] [-TimeoutSeconds <Int32>] [-Proxy <String>] [-ProxyCredential <PSCredential>]
 [-PassThru] [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### OAuth
```
Connect-ServiceNow [-Instance] <String> -Credential <PSCredential> -ClientId <String>
 -ClientSecret <SecureString> [-MaxRetry <Int32>] [-RetryDelaySeconds <Int32>] [-TimeoutSeconds <Int32>]
 [-Proxy <String>] [-ProxyCredential <PSCredential>] [-PassThru] [-ProgressAction <ActionPreference>] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

### Token
```
Connect-ServiceNow [-Instance] <String> -AccessToken <SecureString> [-MaxRetry <Int32>]
 [-RetryDelaySeconds <Int32>] [-TimeoutSeconds <Int32>] [-Proxy <String>] [-ProxyCredential <PSCredential>]
 [-PassThru] [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Stores a ServiceNow connection in the module session context, which every other ServiceNow.API
cmdlet uses by default.
Three authentication methods are supported:

  - Basic: an instance and a credential.
  - OAuth: an instance, a credential and an OAuth application client id and secret.
An access
    token is requested immediately and refreshed automatically before it expires.
  - Token: an instance and a pre-issued OAuth access token.

Credentials and tokens are held in memory only and are never written to disk.

You can connect to more than one instance at once.
Each connection is stored under its instance
name, and the most recently connected instance becomes the session default.
Any cmdlet can then
target a specific instance with -Instance (by name) or -Connection (with an object from
-PassThru); with neither, the default is used.

Rate-limit and transient-error handling is always on: HTTP 429 responses are retried after the
Retry-After delay, and HTTP 502/503/504 are retried with exponential backoff, up to -MaxRetry
attempts.

## EXAMPLES

### EXAMPLE 1
```
Connect-ServiceNow -Instance 'dev12345' -Credential (Get-Credential)
```

Connects with Basic authentication.

### EXAMPLE 2
```
$secret = Read-Host 'Client secret' -AsSecureString
Connect-ServiceNow -Instance 'dev12345' -Credential $cred -ClientId $id -ClientSecret $secret
```

Connects with OAuth and requests an access token immediately.

## PARAMETERS

### -AccessToken
A pre-issued OAuth access token, as a SecureString.
Selects token authentication.

```yaml
Type: SecureString
Parameter Sets: Token
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ClientId
The OAuth application client id.
Supplying this (with -ClientSecret) selects OAuth.

```yaml
Type: String
Parameter Sets: OAuth
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ClientSecret
The OAuth application client secret, as a SecureString.

```yaml
Type: SecureString
Parameter Sets: OAuth
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Credential
The credential used to authenticate.
For Basic this is used on every request; for OAuth it is
the integration user for the password grant.

```yaml
Type: PSCredential
Parameter Sets: Basic, OAuth
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Instance
The ServiceNow instance.
Accepts the short instance name ('dev12345'), a hostname
('dev12345.service-now.com') or a full URL.
It is normalised to the instance base URL.

```yaml
Type: String
Parameter Sets: (All)
Aliases: Url, Server

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MaxRetry
Maximum number of retries for rate-limited and transient failures.
Defaults to 5.
Set to 0 to
disable automatic retries.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 5
Accept pipeline input: False
Accept wildcard characters: False
```

### -PassThru
Return the resulting (masked) connection context.

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

### -Proxy
Optional proxy URL for all requests.

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

### -ProxyCredential
Optional credential for an authenticated proxy.

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RetryDelaySeconds
Base delay, in seconds, for the exponential backoff between retries.
Defaults to 2.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 2
Accept pipeline input: False
Accept wildcard characters: False
```

### -TimeoutSeconds
Optional per-request timeout in seconds.
When 0 (the default) no explicit timeout is applied.

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

### None by default, or a PSCustomObject describing the connection when -PassThru is used.
## NOTES

## RELATED LINKS

[https://github.com/deanlongstaff/ServiceNow.API](https://github.com/deanlongstaff/ServiceNow.API)

