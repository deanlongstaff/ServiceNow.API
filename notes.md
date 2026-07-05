## ServiceNow.API v1.0.1

A documentation-only patch. Fixes malformed comment-based help for the `-Minimum` parameter of `Get-ServiceNowAggregate`, whose description had been garbled with unrelated text and now correctly reads "Fields to take the minimum of." No functional or behavioural changes.

```powershell
Update-Module -Name ServiceNow.API
```

---

## ServiceNow.API v1.0.0

The first release of the most complete community PowerShell module for the ServiceNow REST API. Automate ServiceNow ITSM, ITOM and CMDB from PowerShell: query and manage records on any table, build readable filters, and work with attachments, batch requests, import sets, aggregates, GraphQL, the Service Catalog, the Knowledge Base and Change Management — with authentication, rate limiting and transient-error retries handled for you.

### Highlights

- **Resilient by default** — automatic OAuth token refresh on HTTP 401, rate-limit waiting on HTTP 429 (honouring `Retry-After`), and transient-error retries on HTTP 502/503/504 with exponential backoff. No retry loops to write.
- **Readable, PowerShell-native filtering** — build encoded queries with operators that mimic PowerShell (`-eq`, `-like`, `-gt`, `-between`, …) combined with `and`, `or` and `group`, or paste a raw encoded query straight from the ServiceNow list view.
- **Broad, consistent API coverage** — the Table, Attachment, Batch, Import Set, Aggregate, Service Catalog and Knowledge Management APIs each get first-class cmdlets, plus a generic `Invoke-ServiceNowRestMethod` escape hatch for anything else.
- **Named shortcuts for common tables** — cmdlets such as `Get-ServiceNowIncident`, `Set-ServiceNowCatalogTask` and `New-ServiceNowUser` save you remembering table names and expose the same parameters as the generic cmdlets.
- **Multi-instance in one session** — connect to several instances at once and target any of them per call with `-Instance <name>` (or an explicit `-Connection` object).
- **Automatic pagination** — listing records follows pages for you; cap with `-Limit`.
- **Portable and dependency-free** — runs on PowerShell 7+ and Windows PowerShell 5.1. Credentials and tokens are held in memory only and never written to disk.

### Cmdlets

- **Connection**: `Connect-ServiceNow`, `Disconnect-ServiceNow`, `Get-ServiceNowConnection`, `Get-ServiceNowCurrentUser`
- **Records (Table API)**: `Get-ServiceNowRecord`, `New-ServiceNowRecord`, `Set-ServiceNowRecord` (alias `Update-ServiceNowRecord`), `Remove-ServiceNowRecord`, `New-ServiceNowQuery` and `Export-ServiceNowRecord`
- **Table shortcuts**: `Get`/`New`/`Set` for Incident, ChangeRequest, ChangeTask, Problem, User, Group and ConfigurationItem; `Get`/`Set` for Request, RequestedItem and CatalogTask
- **Comments & work notes**: `Add-ServiceNowComment`, `Add-ServiceNowWorkNote`, `Get-ServiceNowJournalEntry`
- **Attachments**: `Get`/`Add`/`Save`/`Remove-ServiceNowAttachment`
- **Batch / Import / Aggregate**: `Invoke-ServiceNowBatch`, `Import-ServiceNowRecord`, `Get-ServiceNowAggregate`
- **Service Catalog**: `Get-ServiceNowCatalogItem`, `Request-ServiceNowCatalogItem`, `Get-ServiceNowCatalogCart`, `Add-ServiceNowCatalogCartItem`, `Submit-ServiceNowCatalogCart`, `Get-ServiceNowCatalogVariable`
- **CMDB & Change**: `Get-ServiceNowCmdbInstance`, `Invoke-ServiceNowIdentifyReconcile`, `New-ServiceNowChange`
- **Knowledge / discovery / generic**: `Get-ServiceNowKnowledgeArticle`, `Get-ServiceNowTableSchema`, `Invoke-ServiceNowGraphQL`, `Invoke-ServiceNowRestMethod`

### Requirements

- PowerShell 7.2+ or Windows PowerShell 5.1 — no external dependencies.
- A ServiceNow instance and an account with REST access (the `rest_api_explorer`/`web_service_admin` roles or appropriate ACLs). OAuth also needs an application registry entry for the client id and secret.

### Install

```powershell
Install-Module -Name ServiceNow.API -Scope CurrentUser
```

### Quick start

```powershell
Connect-ServiceNow -Instance 'dev12345' -Credential (Get-Credential)

# Get the ten most recent active incidents
Get-ServiceNowIncident -Filter @('active', '-eq', 'true') -Sort @('opened_at', 'desc') -Limit 10

# Create an incident
New-ServiceNowIncident -InputData @{ short_description = 'Laptop will not boot'; urgency = 2 } -PassThru
```

### Documentation

[README](https://github.com/deanlongstaff/ServiceNow.API/blob/main/README.md) · [Examples](https://github.com/deanlongstaff/ServiceNow.API/blob/main/docs/examples.md) · [Cmdlet help](https://github.com/deanlongstaff/ServiceNow.API/tree/main/docs/help) · [Changelog](https://github.com/deanlongstaff/ServiceNow.API/blob/main/CHANGELOG.md)

> An independent, community-maintained module. Not produced or endorsed by ServiceNow. "ServiceNow" is a trademark of ServiceNow, Inc.
