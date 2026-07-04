@{
    RootModule           = 'ServiceNow.API.psm1'
    ModuleVersion        = '1.0.0'
    GUID                 = 'b8f4e2a1-6c3d-4f9a-9e57-2a1b8c4d5e6f'
    Author               = 'Dean Longstaff'
    CompanyName          = 'Dean Longstaff'
    Copyright            = '(c) 2026 Dean Longstaff. All rights reserved.'
    Description          = 'The most complete community PowerShell module for the ServiceNow REST API. Automate ServiceNow ITSM, ITOM and CMDB from PowerShell: query and manage records on any table (incident, change, problem, request, CMDB and more), run advanced filters, and work with attachments, batch requests, import sets, aggregates, GraphQL, the Service Catalog, the Knowledge Base, the CMDB Instance API and Change Management. Handles Basic and OAuth authentication with automatic token refresh, rate-limit (HTTP 429) waiting and transient-error (HTTP 5xx) retries. Works on PowerShell 7 and Windows PowerShell 5.1 with no external dependencies.'

    PowerShellVersion    = '5.1'
    CompatiblePSEditions = @('Core', 'Desktop')

    FunctionsToExport    = @(
        # -- Connection
        'Connect-ServiceNow'
        'Disconnect-ServiceNow'
        'Get-ServiceNowConnection'

        # -- Generic REST access
        'Invoke-ServiceNowRestMethod'

        # -- Table API (CRUD)
        'Get-ServiceNowRecord'
        'New-ServiceNowRecord'
        'Set-ServiceNowRecord'
        'Remove-ServiceNowRecord'

        # -- Query building
        'New-ServiceNowQuery'

        # -- Attachment API
        'Get-ServiceNowAttachment'
        'Add-ServiceNowAttachment'
        'Save-ServiceNowAttachment'
        'Remove-ServiceNowAttachment'

        # -- Batch API
        'Invoke-ServiceNowBatch'

        # -- Import Set API
        'Import-ServiceNowRecord'

        # -- Aggregate API
        'Get-ServiceNowAggregate'

        # -- Service Catalog API
        'Get-ServiceNowCatalogItem'
        'Request-ServiceNowCatalogItem'
        'Get-ServiceNowCatalogCart'
        'Add-ServiceNowCatalogCartItem'
        'Submit-ServiceNowCatalogCart'

        # -- Knowledge Management API
        'Get-ServiceNowKnowledgeArticle'

        # -- Schema discovery
        'Get-ServiceNowTableSchema'

        # -- Table-specific helpers (thin wrappers over the generic Table API cmdlets)
        'Get-ServiceNowIncident'
        'New-ServiceNowIncident'
        'Set-ServiceNowIncident'
        'Get-ServiceNowChangeRequest'
        'New-ServiceNowChangeRequest'
        'Set-ServiceNowChangeRequest'
        'Get-ServiceNowChangeTask'
        'New-ServiceNowChangeTask'
        'Set-ServiceNowChangeTask'
        'Get-ServiceNowProblem'
        'New-ServiceNowProblem'
        'Set-ServiceNowProblem'
        'Get-ServiceNowRequest'
        'Set-ServiceNowRequest'
        'Get-ServiceNowRequestedItem'
        'Set-ServiceNowRequestedItem'
        'Get-ServiceNowCatalogTask'
        'Set-ServiceNowCatalogTask'
        'Get-ServiceNowUser'
        'New-ServiceNowUser'
        'Set-ServiceNowUser'
        'Get-ServiceNowGroup'
        'New-ServiceNowGroup'
        'Set-ServiceNowGroup'
        'Get-ServiceNowConfigurationItem'
        'New-ServiceNowConfigurationItem'
        'Set-ServiceNowConfigurationItem'

        # -- Journal (comments and work notes)
        'Add-ServiceNowComment'
        'Add-ServiceNowWorkNote'
        'Get-ServiceNowJournalEntry'

        # -- Catalog variables
        'Get-ServiceNowCatalogVariable'

        # -- GraphQL
        'Invoke-ServiceNowGraphQL'

        # -- Record export
        'Export-ServiceNowRecord'

        # -- CMDB Instance API and Identification & Reconciliation
        'Get-ServiceNowCmdbInstance'
        'Invoke-ServiceNowIdentifyReconcile'

        # -- Current user
        'Get-ServiceNowCurrentUser'

        # -- Change Management API
        'New-ServiceNowChange'
    )

    CmdletsToExport      = @()
    VariablesToExport    = @()
    AliasesToExport      = @(
        'Update-ServiceNowRecord'
        'gsnr'
    )

    PrivateData          = @{
        PSData = @{
            Tags         = @(
                'ServiceNow', 'SNOW', 'ServiceNowAPI', 'ServiceNowPowerShell', 'ITSM', 'ITOM', 'ITIL',
                'CMDB', 'Incident', 'Change', 'Problem', 'Request', 'RITM', 'ServiceCatalog',
                'KnowledgeBase', 'Table', 'Attachment', 'Batch', 'Import', 'Aggregate', 'GraphQL',
                'REST', 'API', 'OAuth', 'Automation', 'DevOps', 'Integration', 'ServiceDesk',
                'HelpDesk', 'PSModule', 'PSEdition_Core', 'PSEdition_Desktop'
            )
            LicenseUri   = 'https://github.com/deanlongstaff/ServiceNow.API/blob/main/LICENSE'
            ProjectUri   = 'https://github.com/deanlongstaff/ServiceNow.API'
            ReleaseNotes = 'https://github.com/deanlongstaff/ServiceNow.API/blob/main/CHANGELOG.md'
        }
    }
}
