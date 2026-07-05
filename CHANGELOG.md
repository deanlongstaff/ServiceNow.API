# Changelog

All notable changes to the **ServiceNow.API** module are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.1] - 2026-07-05

### Fixed

- Corrected malformed comment-based help for the `-Minimum` parameter of `Get-ServiceNowAggregate`,
  whose description had been garbled with unrelated text and now correctly reads "Fields to take the
  minimum of." Documentation only; no functional change.

## [1.0.0] - 2026-07-04

### Added

- Initial public release covering the most-used ServiceNow REST APIs.
- Connection management with Basic, OAuth (password grant with automatic token refresh) and
  pre-issued token authentication: `Connect-ServiceNow`, `Disconnect-ServiceNow`,
  `Get-ServiceNowConnection`. Connect to several instances at once and target any of them per call
  with `-Instance`; `Get-ServiceNowConnection` supports `-Instance` and `-All` (and reports an
  `IsDefault` property), and `Disconnect-ServiceNow` supports `-Instance` to disconnect one instance.
- Table API CRUD: `Get-ServiceNowRecord` (single, filtered list and automatic pagination),
  `New-ServiceNowRecord`, `Set-ServiceNowRecord` (alias `Update-ServiceNowRecord`) and
  `Remove-ServiceNowRecord`.
- Table-specific helper cmdlets (thin wrappers over the generic Table API cmdlets) so you can skip
  the `-Table` name for common tables — incident, change request, change task, problem, request,
  requested item (RITM), catalog task, user, group and configuration item. They expose the same
  parameters as the generic cmdlets, and the numbered `Get` wrappers add a `-Number` shortcut.
- A readable, PowerShell-native query builder, `New-ServiceNowQuery`, with operators that mimic
  PowerShell and `and`/`or`/`group` joins, usable via `-Filter` on record and aggregate cmdlets or
  as a raw encoded `-Query`.
- Attachment API: `Get-ServiceNowAttachment`, `Add-ServiceNowAttachment`, `Save-ServiceNowAttachment`
  and `Remove-ServiceNowAttachment`.
- Batch API: `Invoke-ServiceNowBatch`.
- Import Set API: `Import-ServiceNowRecord`.
- Aggregate API: `Get-ServiceNowAggregate` (count, average, sum, min, max, group by, having).
- Service Catalog API: `Get-ServiceNowCatalogItem`, `Request-ServiceNowCatalogItem`,
  `Get-ServiceNowCatalogCart`, `Add-ServiceNowCatalogCartItem` and `Submit-ServiceNowCatalogCart`.
- Knowledge Management API: `Get-ServiceNowKnowledgeArticle`.
- Schema discovery: `Get-ServiceNowTableSchema`.
- Journal helpers for comments and work notes: `Add-ServiceNowComment`, `Add-ServiceNowWorkNote` and
  `Get-ServiceNowJournalEntry`.
- Catalog variables: `Get-ServiceNowCatalogVariable` returns the values a user submitted on a
  requested item (RITM).
- GraphQL API: `Invoke-ServiceNowGraphQL`.
- Record export to CSV, XML, PDF or Excel: `Export-ServiceNowRecord`.
- CMDB Instance API (`Get-ServiceNowCmdbInstance`, including relationships) and the Identification and
  Reconciliation API (`Invoke-ServiceNowIdentifyReconcile`).
- `Get-ServiceNowCurrentUser` to show the connected account.
- Change Management API: `New-ServiceNowChange` (normal, standard-from-template and emergency).
- A generic escape hatch, `Invoke-ServiceNowRestMethod`, for any endpoint without a dedicated cmdlet.
- Always-on resilience in the request engine: automatic OAuth token refresh on HTTP 401, rate-limit
  waiting on HTTP 429 (honouring `Retry-After`), and transient-error retries on HTTP 502/503/504 with
  exponential backoff.
- Per-cmdlet Markdown help (platyPS), compiled to MAML external help that ships with the module.
- Pester test suite, PSScriptAnalyzer configuration, GitHub Actions CI/CD, an automated release
  workflow, and documentation.

[Unreleased]: https://github.com/deanlongstaff/ServiceNow.API/compare/v1.0.1...HEAD
[1.0.1]: https://github.com/deanlongstaff/ServiceNow.API/releases/tag/v1.0.1
[1.0.0]: https://github.com/deanlongstaff/ServiceNow.API/releases/tag/v1.0.0
