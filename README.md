# ServiceNow.API

[![CI](https://github.com/deanlongstaff/ServiceNow.API/actions/workflows/ci.yml/badge.svg)](https://github.com/deanlongstaff/ServiceNow.API/actions/workflows/ci.yml)
[![PowerShell Gallery Version](https://img.shields.io/powershellgallery/v/ServiceNow.API)](https://www.powershellgallery.com/packages/ServiceNow.API)
[![PowerShell Gallery Downloads](https://img.shields.io/powershellgallery/dt/ServiceNow.API)](https://www.powershellgallery.com/packages/ServiceNow.API)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

**The most complete community PowerShell module for the ServiceNow REST API.** Automate ServiceNow
ITSM, ITOM and CMDB from PowerShell — on PowerShell 7 and Windows PowerShell 5.1, with no external
dependencies.

`ServiceNow.API` is a comprehensive PowerShell client for the
[ServiceNow](https://www.servicenow.com/) REST API. Query and manage records on any table (incidents,
changes, problems, requests, CMDB CIs and more), build readable filters, and work with attachments,
batch requests, import sets, aggregates, GraphQL, the Service Catalog, the Knowledge Base and the
CMDB — all from PowerShell. It handles Basic and OAuth authentication, automatic token refresh, rate
limiting (HTTP 429) and transient-error (HTTP 5xx) retries for you, so your scripts stay simple and
reliable.

> This is an independent, community-maintained module and is not produced or endorsed by ServiceNow.
> "ServiceNow" is a trademark of ServiceNow, Inc.

## Why ServiceNow.API is the most complete ServiceNow PowerShell module

- **Resilient by default.** Every request automatically refreshes expired OAuth tokens, waits out
  rate limits (HTTP 429, honouring `Retry-After`), and retries transient server errors
  (HTTP 502/503/504) with exponential backoff. You do not have to write retry loops.
- **Readable, PowerShell-native filtering.** Build encoded queries with operators that mimic
  PowerShell (`-eq`, `-like`, `-gt`, `-between`, …) combined with `and`, `or` and `group` — or paste
  a raw encoded query straight from the ServiceNow list view. Both work everywhere a filter is
  accepted.
- **Broad, consistent API coverage.** The Table, Attachment, Batch, Import Set, Aggregate, Service
  Catalog and Knowledge Management APIs each get first-class cmdlets, plus a generic
  `Invoke-ServiceNowRestMethod` escape hatch for anything else — all with the same authentication,
  retry and paging behaviour.
- **Named shortcuts for common tables.** Cmdlets such as `Get-ServiceNowIncident`,
  `Set-ServiceNowCatalogTask` and `New-ServiceNowUser` save you remembering table names, and expose
  the exact same parameters as the generic cmdlets (they are thin wrappers that always stay in sync).
- **Automatic pagination.** Listing records follows pages for you; cap the result with `-Limit` when
  you only need the first N.
- **Multi-instance in one session.** Connect to several instances at once, then target any of them
  per call with `-Instance <name>` (or an explicit `-Connection` object). With neither, the most
  recently connected instance is used.
- **Discoverable and documented.** Consistent verb-noun naming, full comment-based help with
  examples on every cmdlet, and a schema-discovery cmdlet (`Get-ServiceNowTableSchema`) to explore
  unfamiliar tables.
- **Portable and dependency-free.** Runs on **PowerShell 7+** and **Windows PowerShell 5.1** with no
  external modules. Credentials and tokens are held in memory only and never written to disk.

## Requirements

- PowerShell 7.2 or later, or Windows PowerShell 5.1.
- A ServiceNow instance and an account with REST access (the `rest_api_explorer`/`web_service_admin`
  roles or appropriate ACLs). OAuth requires an application registry entry for the client id and
  secret.

## Installation

```powershell
Install-Module -Name ServiceNow.API -Scope CurrentUser
```

## Quick start

```powershell
Import-Module ServiceNow.API

# Connect once; credentials are held in memory for the session only.
Connect-ServiceNow -Instance 'dev12345' -Credential (Get-Credential)

# Get the ten most recent active incidents.
Get-ServiceNowRecord -Table incident -Filter @('active', '-eq', 'true') -Sort @('opened_at', 'desc') -Limit 10

# Create an incident and return it.
New-ServiceNowRecord -Table incident -InputData @{
    short_description = 'Laptop will not boot'
    urgency           = 2
} -PassThru
```

## Authentication

Three authentication methods are supported. Credentials and tokens are held in memory only and are
never written to disk.

```powershell
# Basic
Connect-ServiceNow -Instance 'dev12345' -Credential (Get-Credential)

# OAuth (password grant); the access token is refreshed automatically before it expires
$clientSecret = Read-Host 'Client secret' -AsSecureString
Connect-ServiceNow -Instance 'dev12345' -Credential $cred -ClientId $clientId -ClientSecret $clientSecret

# Pre-issued OAuth access token
$token = Read-Host 'Access token' -AsSecureString
Connect-ServiceNow -Instance 'dev12345' -AccessToken $token
```

`Connect-ServiceNow` accepts the short instance name (`dev12345`), a hostname
(`dev12345.service-now.com`) or a full URL. You can connect to several instances at once; the most
recently connected becomes the default. Target a specific one per call with `-Instance <name>`, or
capture a connection object with `-PassThru` and pass it to a cmdlet's `-Connection` parameter.
`-MaxRetry` and `-RetryDelaySeconds` tune the automatic retry behaviour (set `-MaxRetry 0` to
disable retries).

## Filtering and queries

Build a filter from conditions and joins, or supply a raw encoded query:

```powershell
# Structured filter (operators mimic PowerShell)
Get-ServiceNowRecord -Table incident -Filter @('priority', '-le', '2'), 'and', @('active', '-eq', 'true')

# Raw encoded query, copied from the ServiceNow list view
Get-ServiceNowRecord -Table incident -Query 'active=true^priority<=2'

# Build a reusable query string
$q = New-ServiceNowQuery -Filter @('state', '-eq', '1'), 'or', @('state', '-eq', '2') -Sort @('opened_at', 'desc')
```

Supported operators include `-eq`, `-ne`, `-lt`, `-le`, `-gt`, `-ge`, `-like`, `-notlike`,
`-startswith`, `-endswith`, `-in`, `-notin`, `-between`, `-isempty`, `-isnotempty`. Combine
conditions with `and`, `or` and `group`.

## Cmdlet reference

| Cmdlet                               | REST endpoint                                           | Purpose                                                                               |
| ------------------------------------ | ------------------------------------------------------- | ------------------------------------------------------------------------------------- |
| `Connect-ServiceNow`                 | –                                                       | Store a connection (Basic, OAuth or token).                                           |
| `Disconnect-ServiceNow`              | –                                                       | Clear one (`-Instance`) or all stored connections.                                    |
| `Get-ServiceNowConnection`           | –                                                       | Show the default, a named (`-Instance`) or all (`-All`) connections (secrets masked). |
| `Get-ServiceNowRecord`               | `GET /api/now/table/{table}`                            | Get one record or a filtered, paginated list.                                         |
| `New-ServiceNowRecord`               | `POST /api/now/table/{table}`                           | Create a record.                                                                      |
| `Set-ServiceNowRecord`               | `PATCH /api/now/table/{table}/{id}`                     | Update a record (alias `Update-ServiceNowRecord`).                                    |
| `Remove-ServiceNowRecord`            | `DELETE /api/now/table/{table}/{id}`                    | Delete a record.                                                                      |
| `New-ServiceNowQuery`                | –                                                       | Build an encoded query string.                                                        |
| `Get-ServiceNowAttachment`           | `GET /api/now/attachment`                               | List or get attachment metadata.                                                      |
| `Add-ServiceNowAttachment`           | `POST /api/now/attachment/file`                         | Upload and attach a file to a record.                                                 |
| `Save-ServiceNowAttachment`          | `GET /api/now/attachment/{id}/file`                     | Download an attachment to disk.                                                       |
| `Remove-ServiceNowAttachment`        | `DELETE /api/now/attachment/{id}`                       | Delete an attachment.                                                                 |
| `Invoke-ServiceNowBatch`             | `POST /api/now/v1/batch`                                | Run several requests in one batch call.                                               |
| `Import-ServiceNowRecord`            | `POST /api/now/import/{table}`                          | Load data through an import set.                                                      |
| `Get-ServiceNowAggregate`            | `GET /api/now/stats/{table}`                            | Count and aggregate server-side.                                                      |
| `Get-ServiceNowCatalogItem`          | `GET /api/sn_sc/servicecatalog/items`                   | List, search or get catalog items.                                                    |
| `Request-ServiceNowCatalogItem`      | `POST /api/sn_sc/servicecatalog/items/{id}/order_now`   | Order a catalog item directly.                                                        |
| `Add-ServiceNowCatalogCartItem`      | `POST /api/sn_sc/servicecatalog/items/{id}/add_to_cart` | Add an item to the cart.                                                              |
| `Get-ServiceNowCatalogCart`          | `GET /api/sn_sc/servicecatalog/cart`                    | View the current cart.                                                                |
| `Submit-ServiceNowCatalogCart`       | `POST /api/sn_sc/servicecatalog/cart/submit_order`      | Submit the cart as an order.                                                          |
| `Get-ServiceNowKnowledgeArticle`     | `GET /api/sn_km_api/knowledge/articles`                 | Search or get Knowledge Base articles.                                                |
| `Get-ServiceNowTableSchema`          | `GET /api/now/table/sys_dictionary`                     | Describe a table's columns.                                                           |
| `Add-ServiceNowComment`              | `PATCH /api/now/table/{table}/{id}`                     | Add a customer-visible comment.                                                       |
| `Add-ServiceNowWorkNote`             | `PATCH /api/now/table/{table}/{id}`                     | Add an internal work note.                                                            |
| `Get-ServiceNowJournalEntry`         | `GET /api/now/table/sys_journal_field`                  | Read a record's comments and work notes.                                              |
| `Get-ServiceNowCatalogVariable`      | `GET /api/now/table/sc_item_option_mtom`                | Get the variable values submitted on a RITM.                                          |
| `Invoke-ServiceNowGraphQL`           | `POST /api/now/graphql`                                 | Run a GraphQL query across related tables.                                            |
| `Export-ServiceNowRecord`            | `GET /{table}_list.do`                                  | Export records to CSV, XML, PDF or Excel.                                             |
| `Get-ServiceNowCmdbInstance`         | `GET /api/now/cmdb/instance/{class}`                    | Read CIs (with relationships) via the CMDB API.                                       |
| `Invoke-ServiceNowIdentifyReconcile` | `POST /api/now/identifyreconcile`                       | Insert/update CIs with de-duplication (IRE).                                          |
| `Get-ServiceNowCurrentUser`          | `GET /api/now/ui/user/current_user`                     | Show the connected account.                                                           |
| `New-ServiceNowChange`               | `POST /api/sn_chg_rest/change`                          | Create a change via the Change Management API.                                        |
| `Invoke-ServiceNowRestMethod`        | any                                                     | Call any endpoint with auth and retries handled.                                      |

Run `Get-Help <cmdlet> -Full` for full parameter details and examples. Per-cmdlet reference
documentation is generated under [docs/help/](docs/help), and scenario examples are in
[docs/examples.md](docs/examples.md).

### Table shortcuts

For common tables you can skip the `-Table` name and use a named cmdlet instead. These are thin
wrappers over `Get`/`New`/`Set-ServiceNowRecord`, so they accept the **same** parameters (`-Filter`,
`-Query`, `-Sort`, `-Fields`, `-Limit`, `-Instance`, …). The `Get` wrappers for numbered tables add a
`-Number` shortcut.

| Table                | Cmdlets                                                                                                 |
| -------------------- | ------------------------------------------------------------------------------------------------------- |
| `incident`           | `Get-ServiceNowIncident`, `New-ServiceNowIncident`, `Set-ServiceNowIncident`                            |
| `change_request`     | `Get-ServiceNowChangeRequest`, `New-ServiceNowChangeRequest`, `Set-ServiceNowChangeRequest`             |
| `change_task`        | `Get-ServiceNowChangeTask`, `New-ServiceNowChangeTask`, `Set-ServiceNowChangeTask`                      |
| `problem`            | `Get-ServiceNowProblem`, `New-ServiceNowProblem`, `Set-ServiceNowProblem`                               |
| `sc_request`         | `Get-ServiceNowRequest`, `Set-ServiceNowRequest`                                                        |
| `sc_req_item` (RITM) | `Get-ServiceNowRequestedItem`, `Set-ServiceNowRequestedItem`                                            |
| `sc_task` (SCTASK)   | `Get-ServiceNowCatalogTask`, `Set-ServiceNowCatalogTask`                                                |
| `sys_user`           | `Get-ServiceNowUser`, `New-ServiceNowUser`, `Set-ServiceNowUser`                                        |
| `sys_user_group`     | `Get-ServiceNowGroup`, `New-ServiceNowGroup`, `Set-ServiceNowGroup`                                     |
| `cmdb_ci`            | `Get-ServiceNowConfigurationItem`, `New-ServiceNowConfigurationItem`, `Set-ServiceNowConfigurationItem` |

```powershell
Get-ServiceNowIncident -Number 'INC0010023'
Get-ServiceNowCatalogTask -Query 'active=true^assigned_to=NULL' | Set-ServiceNowCatalogTask -InputData @{ assignment_group = 'Fulfilment' }
New-ServiceNowUser -InputData @{ user_name = 'jdoe'; email = 'jdoe@example.com' } -PassThru
```

For any other table, use the generic `Get`/`New`/`Set`/`Remove-ServiceNowRecord` with `-Table`.

## Common scenarios

### Update records via the pipeline

```powershell
Get-ServiceNowRecord -Table incident -Query 'active=true^assignment_group=NULL' |
    Set-ServiceNowRecord -InputData @{ assignment_group = 'Service Desk' }
```

### Attach and download files

```powershell
Add-ServiceNowAttachment -Table incident -Sys_ID $sysId -Path .\evidence.png
Get-ServiceNowAttachment -Table incident -Sys_ID $sysId | Save-ServiceNowAttachment -Path .\downloads
```

### Count without pulling records

```powershell
Get-ServiceNowAggregate -Table incident -Count -GroupBy priority
```

### Do more in fewer calls with a batch

```powershell
Invoke-ServiceNowBatch -Request @(
    @{ Id = 'open'; Method = 'GET'; Url = '/api/now/table/incident?sysparm_query=active=true&sysparm_limit=1' }
    @{ Id = 'new'; Method = 'POST'; Url = '/api/now/table/incident'; Body = @{ short_description = 'Batch created' } }
)
```

### Call an endpoint that has no dedicated cmdlet

```powershell
Invoke-ServiceNowRestMethod -Path 'api/now/table/change_request' -Query @{ sysparm_limit = 5 }
```

### Work with more than one instance

```powershell
# Connect to two instances; the last one connected is the default.
Connect-ServiceNow -Instance 'dev12345' -Credential $devCred
Connect-ServiceNow -Instance 'prod98765' -Credential $prodCred

# Target a specific instance by name; throws if it is not connected.
Get-ServiceNowRecord -Table incident -Limit 5 -Instance 'dev12345'
New-ServiceNowRecord -Table incident -InputData @{ short_description = 'Prod issue' } -Instance 'prod98765'

Get-ServiceNowConnection -All                # see every connected instance
Disconnect-ServiceNow -Instance 'dev12345'   # disconnect just one
```

## Error handling

Cmdlets throw a terminating error when ServiceNow rejects a request. The message includes the HTTP
status code and the ServiceNow error text, and the exception carries the status code under
`Data['ServiceNowStatusCode']` so you can branch on it:

```powershell
try {
    Get-ServiceNowRecord -Table incident -Sys_ID $id
}
catch {
    if ($_.Exception.Data['ServiceNowStatusCode'] -eq 403) {
        Write-Warning 'You do not have access to that record.'
    }
    else {
        throw
    }
}
```

## Development

```powershell
# Lint and run the full Pester suite (installs Pester and PSScriptAnalyzer on demand).
./build.ps1 -Task Test

# Lint only.
./build.ps1 -Task Analyze

# Regenerate the per-cmdlet Markdown help after changing comment-based help.
./build.ps1 -Task Docs

# Import from source for manual testing.
Import-Module ./src/ServiceNow.API/ServiceNow.API.psd1 -Force
```

The per-cmdlet Markdown help under `docs/help/` is generated from the comment-based help with
[platyPS](https://github.com/PowerShell/platyPS) and is checked into the repository; CI fails if it
is out of date. It is compiled to MAML external help and shipped with the module at publish time.

See [CONTRIBUTING.md](CONTRIBUTING.md) for the full contributor guide.

## Frequently asked questions

### How do I connect to ServiceNow from PowerShell?

Install the module from the PowerShell Gallery with `Install-Module ServiceNow.API`, then run
`Connect-ServiceNow -Instance 'yourinstance' -Credential (Get-Credential)`. After that, every cmdlet
works against your instance. See [Quick start](#quick-start).

### Does it support OAuth, and does it refresh tokens automatically?

Yes. Connect with `-ClientId`/`-ClientSecret` for the OAuth password grant, or pass a pre-issued
`-AccessToken`. OAuth access tokens are refreshed automatically before they expire — you never manage
tokens yourself.

### Does the module handle ServiceNow rate limiting and transient errors?

Yes, automatically. HTTP 429 responses are retried after the `Retry-After` delay, and HTTP 502/503/504
are retried with exponential backoff. You do not have to write retry loops.

### Which ServiceNow REST APIs does it support?

The Table, Attachment, Batch, Import Set, Aggregate, Service Catalog, Knowledge Management, CMDB
Instance, Identification and Reconciliation (IRE), GraphQL and Change Management APIs — plus a generic
`Invoke-ServiceNowRestMethod` for any endpoint without a dedicated cmdlet.

### Can I create incidents, changes and other records from PowerShell?

Yes. Use the generic `New-ServiceNowRecord -Table …`, or the named shortcuts such as
`New-ServiceNowIncident`, `New-ServiceNowChangeRequest` and `New-ServiceNowUser`. Reading and updating
work the same way with `Get-` and `Set-` cmdlets.

### Does it work on Windows PowerShell 5.1 as well as PowerShell 7?

Yes — the module runs on **PowerShell 7+** and **Windows PowerShell 5.1** (Windows, Linux and macOS),
with no external dependencies.

## License

Released under the [MIT License](LICENSE). © Dean Longstaff.
