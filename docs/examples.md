# ServiceNow.API examples

Practical, copy-pasteable examples. They assume you have connected with `Connect-ServiceNow`. In
every example you can add `-Connection $conn` to target a specific instance instead of the session.

## Contents

- [Connecting](#connecting)
- [Reading records](#reading-records)
- [Filtering and sorting](#filtering-and-sorting)
- [Creating, updating and deleting](#creating-updating-and-deleting)
- [Table shortcuts](#table-shortcuts)
- [Attachments](#attachments)
- [Aggregates](#aggregates)
- [Batch requests](#batch-requests)
- [Import sets](#import-sets)
- [Service Catalog](#service-catalog)
- [Knowledge Base](#knowledge-base)
- [Discovering a table](#discovering-a-table)
- [Comments and work notes](#comments-and-work-notes)
- [Catalog variables, GraphQL and export](#catalog-variables-graphql-and-export)
- [CMDB and change](#cmdb-and-change)
- [Calling any endpoint](#calling-any-endpoint)
- [Working with multiple instances](#working-with-multiple-instances)

## Connecting

```powershell
# Basic authentication
Connect-ServiceNow -Instance 'dev12345' -Credential (Get-Credential)

# OAuth (token refreshed automatically)
$secret = Read-Host 'Client secret' -AsSecureString
Connect-ServiceNow -Instance 'dev12345' -Credential $cred -ClientId $clientId -ClientSecret $secret

# Tune resilience: retry up to 8 times, starting at a 3s backoff
Connect-ServiceNow -Instance 'dev12345' -Credential $cred -MaxRetry 8 -RetryDelaySeconds 3
```

## Reading records

```powershell
# A single record by sys_id
Get-ServiceNowRecord -Table incident -Sys_ID '46b66a40a9fe198101f243dfbc79033d'

# Every active incident (pages are followed automatically)
Get-ServiceNowRecord -Table incident -Query 'active=true'

# Just the first 25, with only two fields, newest first
Get-ServiceNowRecord -Table incident -Query 'active=true' -Sort @('opened_at', 'desc') -Fields number, short_description -Limit 25

# Return display values instead of raw values
Get-ServiceNowRecord -Table incident -Sys_ID $id -DisplayValue true
```

## Filtering and sorting

```powershell
# Structured filter with AND
Get-ServiceNowRecord -Table incident -Filter @('active', '-eq', 'true'), 'and', @('priority', '-le', '2')

# OR and grouping
$filter = @('state', '-eq', '1'), 'group', @('state', '-eq', '2')
Get-ServiceNowRecord -Table incident -Filter $filter

# Date ranges
Get-ServiceNowRecord -Table incident -Filter @('opened_at', '-between', (Get-Date).AddDays(-7), (Get-Date))

# Reuse a query string
$q = New-ServiceNowQuery -Filter @('assigned_to.name', '-like', 'Abel Tuter') -Sort @('opened_at', 'desc')
Get-ServiceNowRecord -Table incident -Query $q
```

## Creating, updating and deleting

```powershell
# Create
$incident = New-ServiceNowRecord -Table incident -InputData @{
    short_description = 'Printer offline'
    urgency           = 2
    impact            = 2
} -PassThru

# Update
Set-ServiceNowRecord -Table incident -Sys_ID $incident.sys_id -InputData @{ state = 2; work_notes = 'Investigating' }

# Update many via the pipeline (Update-ServiceNowRecord is an alias of Set-ServiceNowRecord)
Get-ServiceNowRecord -Table incident -Query 'assignment_group=NULL^active=true' |
    Update-ServiceNowRecord -InputData @{ assignment_group = 'Service Desk' }

# Delete
Remove-ServiceNowRecord -Table incident -Sys_ID $incident.sys_id -Confirm:$false
```

## Table shortcuts

For common tables you can use a named cmdlet instead of `-Table`. These are thin wrappers over the
generic cmdlets and take the same parameters; the numbered `Get` wrappers add `-Number`.

```powershell
# Instead of Get-ServiceNowRecord -Table incident ...
Get-ServiceNowIncident -Number 'INC0010023'
Get-ServiceNowIncident -Filter @('active', '-eq', 'true') -Sort @('opened_at', 'desc') -Limit 10

# Create / update
New-ServiceNowIncident -InputData @{ short_description = 'Printer offline'; urgency = 2 } -PassThru
Get-ServiceNowCatalogTask -Query 'active=true^assigned_to=NULL' |
    Set-ServiceNowCatalogTask -InputData @{ assignment_group = 'Fulfilment' }

# Identity and CMDB
Get-ServiceNowUser -Query 'user_name=abel.tuter'
New-ServiceNowGroup -InputData @{ name = 'Network Team' } -PassThru
Get-ServiceNowConfigurationItem -Query 'name=EXCHANGE01'

# They also accept -Instance to target a specific connection
Get-ServiceNowIncident -Number 'INC0010023' -Instance 'prod98765'
```

Available shortcuts: Incident, ChangeRequest, ChangeTask, Problem, Request, RequestedItem,
CatalogTask, User, Group and ConfigurationItem. For any other table, use the generic
`Get`/`New`/`Set`/`Remove-ServiceNowRecord`.

## Attachments

```powershell
# Upload
Add-ServiceNowAttachment -Table incident -Sys_ID $sysId -Path .\diagnostic.log

# List
$files = Get-ServiceNowAttachment -Table incident -Sys_ID $sysId

# Download all attachments on a record
$files | Save-ServiceNowAttachment -Path .\downloads

# Delete
$files | Where-Object file_name -eq 'diagnostic.log' | Remove-ServiceNowAttachment -Confirm:$false
```

## Aggregates

```powershell
# Total active incidents
Get-ServiceNowAggregate -Table incident -Count -Filter @('active', '-eq', 'true')

# Count grouped by priority
Get-ServiceNowAggregate -Table incident -Count -GroupBy priority

# Average and maximum reassignment count
Get-ServiceNowAggregate -Table incident -Average reassignment_count -Maximum reassignment_count
```

## Batch requests

```powershell
$results = Invoke-ServiceNowBatch -Request @(
    @{ Id = 'p1'; Method = 'GET'; Url = '/api/now/table/problem?sysparm_limit=1' }
    @{ Id = 'i1'; Method = 'POST'; Url = '/api/now/table/incident'; Body = @{ short_description = 'From batch' } }
)
$results | Where-Object Serviced | Select-Object Id, StatusCode
```

## Import sets

```powershell
Import-ServiceNowRecord -StagingTable u_imp_user -InputData @{
    u_user_name = 'jdoe'
    u_email     = 'jdoe@example.com'
} -PassThru
```

## Service Catalog

```powershell
# Find an item
$item = Get-ServiceNowCatalogItem -Query 'laptop' | Select-Object -First 1

# Order it directly
Request-ServiceNowCatalogItem -Sys_ID $item.sys_id -Variable @{ requested_for = $userSysId }

# Or build a cart and submit
Add-ServiceNowCatalogCartItem -Sys_ID $item.sys_id -Quantity 1
Get-ServiceNowCatalogCart
Submit-ServiceNowCatalogCart
```

## Knowledge Base

```powershell
# Search
Get-ServiceNowKnowledgeArticle -Query 'reset password' -Limit 5

# Retrieve one article and its content
Get-ServiceNowKnowledgeArticle -ArticleId 'KB0010001'
```

## Discovering a table

```powershell
# List the fields defined on a table
Get-ServiceNowTableSchema -Table incident

# Find the mandatory fields
Get-ServiceNowTableSchema -Table incident | Where-Object Mandatory -eq 'true' | Select-Object Element, Label, Type
```

## Comments and work notes

```powershell
Add-ServiceNowComment  -Table incident -Sys_ID $sysId -Text 'We are investigating.'
Add-ServiceNowWorkNote -Table incident -Sys_ID $sysId -Text 'Restarted the print spooler.'

# Read the journal (newest first)
Get-ServiceNowJournalEntry -Sys_ID $sysId -Type work_notes
```

## Catalog variables, GraphQL and export

```powershell
# What did the user submit on this RITM?
Get-ServiceNowRequestedItem -Number 'RITM0010001' | Get-ServiceNowCatalogVariable

# One round-trip across related tables
$q = 'query { GlideRecord_Query { incident(queryConditions: "active=true", limit: 5) { _results { number { value } } } } }'
Invoke-ServiceNowGraphQL -Query $q

# Export a filtered list to Excel
Export-ServiceNowRecord -Table incident -Filter @('active', '-eq', 'true') -Fields number, short_description -Path .\incidents.xlsx
```

## CMDB and change

```powershell
# Class-aware CMDB read, with relationships
Get-ServiceNowCmdbInstance -Class cmdb_ci_linux_server -Sys_ID $ciSysId

# Ingest CIs with de-duplication (IRE)
$payload = @{ items = @(@{ className = 'cmdb_ci_linux_server'; values = @{ name = 'app-svr-07'; serial_number = 'SN-12345' } }) }
Invoke-ServiceNowIdentifyReconcile -InputData $payload -DataSource 'MyIntegration'

# Create a change through the Change Management API
New-ServiceNowChange -Type normal -InputData @{ short_description = 'Upgrade firmware' } -PassThru
New-ServiceNowChange -Type standard -Template $templateSysId -PassThru

# Who am I connected as?
Get-ServiceNowCurrentUser
```

## Calling any endpoint

```powershell
# Anything without a dedicated cmdlet still gets auth, retries and paging headers
Invoke-ServiceNowRestMethod -Path 'api/now/table/change_request' -Query @{ sysparm_limit = 5 }

Invoke-ServiceNowRestMethod -Method POST -Path 'api/now/table/incident' -Body @{ short_description = 'Direct call' }
```

## Working with multiple instances

```powershell
$dev = Connect-ServiceNow -Instance 'dev12345' -Credential $devCred -PassThru
$test = Connect-ServiceNow -Instance 'test67890' -Credential $testCred -PassThru

# The last connection is the session default; target the other with -Connection
Get-ServiceNowRecord -Table incident -Limit 5 -Connection $dev
Get-ServiceNowRecord -Table incident -Limit 5 -Connection $test
```
