#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
    Pester tests for New-ServiceNowQuery, the encoded-query builder.
#>

BeforeAll {
    Import-Module "$PSScriptRoot/../src/ServiceNow.API/ServiceNow.API.psd1" -Force
}

Describe 'New-ServiceNowQuery' {

    Context 'Single conditions' {

        It 'builds a simple equals condition' {
            New-ServiceNowQuery -Filter @('active', '-eq', 'true') | Should -Be 'active=true'
        }

        It 'maps comparison operators' {
            New-ServiceNowQuery -Filter @('priority', '-ne', '1') | Should -Be 'priority!=1'
            New-ServiceNowQuery -Filter @('priority', '-gt', '2') | Should -Be 'priority>2'
            New-ServiceNowQuery -Filter @('priority', '-le', '3') | Should -Be 'priority<=3'
        }

        It 'maps text operators' {
            New-ServiceNowQuery -Filter @('short_description', '-like', 'network') | Should -Be 'short_descriptionLIKEnetwork'
            New-ServiceNowQuery -Filter @('number', '-startswith', 'INC') | Should -Be 'numberSTARTSWITHINC'
        }

        It 'handles value-less operators' {
            New-ServiceNowQuery -Filter @('assigned_to', '-isempty') | Should -Be 'assigned_toISEMPTY'
            New-ServiceNowQuery -Filter @('assigned_to', '-isnotempty') | Should -Be 'assigned_toISNOTEMPTY'
        }

        It 'builds a BETWEEN condition from two values' {
            $Result = New-ServiceNowQuery -Filter @('priority', '-between', 1, 3)
            $Result | Should -Be 'priorityBETWEEN1@3'
        }

        It 'formats datetime values' {
            $Start = [datetime]'2026-01-01T00:00:00'
            $End = [datetime]'2026-01-31T23:59:59'
            $Result = New-ServiceNowQuery -Filter @('sys_created_on', '-between', $Start, $End)
            $Result | Should -Be 'sys_created_onBETWEEN2026-01-01 00:00:00@2026-01-31 23:59:59'
        }
    }

    Context 'Joins' {

        It 'combines conditions with an OR join' {
            $Filter = @('state', '-eq', '1'), 'or', @('short_description', '-like', 'network')
            New-ServiceNowQuery -Filter $Filter | Should -Be 'state=1^ORshort_descriptionLIKEnetwork'
        }

        It 'combines conditions with an AND join' {
            $Filter = @('active', '-eq', 'true'), 'and', @('priority', '-le', '2')
            New-ServiceNowQuery -Filter $Filter | Should -Be 'active=true^priority<=2'
        }

        It 'supports the group (new query) join' {
            $Filter = @('state', '-eq', '1'), 'group', @('state', '-eq', '2')
            New-ServiceNowQuery -Filter $Filter | Should -Be 'state=1^NQstate=2'
        }
    }

    Context 'Sorting' {

        It 'appends ascending and descending sorts' {
            New-ServiceNowQuery -Filter @('active', '-eq', 'true') -Sort @('opened_at', 'desc') |
                Should -Be 'active=true^ORDERBYDESCopened_at'
        }

        It 'supports multiple sort fields' {
            $Sort = @('priority', 'asc'), @('opened_at', 'desc')
            New-ServiceNowQuery -Filter @('active', '-eq', 'true') -Sort $Sort |
                Should -Be 'active=true^ORDERBYpriority^ORDERBYDESCopened_at'
        }

        It 'returns only the sort when no filter is provided' {
            New-ServiceNowQuery -Sort @('number', 'asc') | Should -Be '^ORDERBYnumber'
        }
    }

    Context 'Validation' {

        It 'throws on an unknown operator' {
            { New-ServiceNowQuery -Filter @('field', '-contains', 'x') } | Should -Throw '*Unknown operator*'
        }

        It 'throws when -between is missing a value' {
            { New-ServiceNowQuery -Filter @('field', '-between', 1) } | Should -Throw '*requires two values*'
        }

        It 'returns an empty string for no filter or sort' {
            New-ServiceNowQuery | Should -Be ''
        }
    }
}
