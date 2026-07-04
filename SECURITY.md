# Security Policy

## Supported versions

The latest released version on the PowerShell Gallery receives security updates.

## Reporting a vulnerability

**Do not open a public issue for security vulnerabilities.**

If you believe you have found a security vulnerability in this module, please report it privately
using [GitHub's private vulnerability reporting](https://docs.github.com/code-security/security-advisories/guidance-on-reporting-and-writing/privately-reporting-a-security-vulnerability)
on this repository, or by contacting the maintainers directly.

Please include:

- A description of the vulnerability and its impact.
- Steps to reproduce.
- Any suggested remediation.

We will acknowledge your report as soon as possible and keep you informed of progress toward a fix.

## Handling of credentials

- This module never logs or persists your ServiceNow credentials or tokens. They are held only in
  memory for the duration of your session (via `Connect-ServiceNow`) and are used solely to
  authenticate API requests.
- `Get-ServiceNowConnection` never returns passwords or tokens; it shows only the connected user
  name and non-secret connection details.
- OAuth access tokens are refreshed automatically and kept in memory only.
- Never commit credentials or tokens to source control. If a client secret or token is exposed,
  revoke it in the ServiceNow instance (System OAuth / user administration) immediately.
