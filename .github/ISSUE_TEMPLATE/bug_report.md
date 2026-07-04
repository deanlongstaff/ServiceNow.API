---
name: Bug report
about: Report a problem with the ServiceNow.API module
title: "[Bug] "
labels: bug
---

## Describe the bug

A clear and concise description of what the bug is.

## To reproduce

Steps or a minimal code sample that reproduces the problem. **Do not include credentials, tokens or
any personal data.**

```powershell
# Example
Connect-ServiceNow -Instance 'dev12345' -Credential $cred
Get-ServiceNowRecord -Table incident -Query 'active=true'
```

## Expected behaviour

What you expected to happen.

## Actual behaviour

What actually happened, including the full error message (with any secrets redacted).

## Environment

- Module version: <!-- (Get-Module ServiceNow.API).Version -->
- PowerShell edition and version: <!-- $PSVersionTable.PSEdition / .PSVersion -->
- Operating system:

## Additional context

Anything else that might help.
