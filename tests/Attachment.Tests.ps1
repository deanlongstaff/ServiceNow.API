#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
    Pester tests for the Attachment API cmdlets: Get/Add/Save/Remove-ServiceNowAttachment.
#>

BeforeAll {
    Import-Module "$PSScriptRoot/../src/ServiceNow.API/ServiceNow.API.psd1" -Force
    $script:TempFile = Join-Path $TestDrive 'sample.txt'
    'hello world' | Set-Content -Path $script:TempFile
}

Describe 'Get-ServiceNowAttachment' {

    It 'lists attachments for a record' {
        Mock -ModuleName ServiceNow.API Invoke-ServiceNowApi { @{ result = @(@{ sys_id = 'att1'; file_name = 'a.txt' }) } }
        $Result = Get-ServiceNowAttachment -Table incident -Sys_ID 'abc'
        $Result.file_name | Should -Be 'a.txt'
        Should -Invoke -ModuleName ServiceNow.API Invoke-ServiceNowApi -Times 1 -ParameterFilter {
            $Path -eq 'api/now/attachment' -and $Query['sysparm_query'] -eq 'table_name=incident^table_sys_id=abc'
        }
    }

    It 'gets a single attachment by id' {
        Mock -ModuleName ServiceNow.API Invoke-ServiceNowApi { @{ result = @{ sys_id = 'att1' } } }
        Get-ServiceNowAttachment -AttachmentId 'att1'
        Should -Invoke -ModuleName ServiceNow.API Invoke-ServiceNowApi -Times 1 -ParameterFilter {
            $Path -eq 'api/now/attachment/att1'
        }
    }

    It 'adds a file name filter when listing a record' {
        Mock -ModuleName ServiceNow.API Invoke-ServiceNowApi { @{ result = @() } }
        Get-ServiceNowAttachment -Table incident -Sys_ID 'abc' -FileName 'report'
        Should -Invoke -ModuleName ServiceNow.API Invoke-ServiceNowApi -Times 1 -ParameterFilter {
            $Query['sysparm_query'] -eq 'table_name=incident^table_sys_id=abc^file_nameLIKEreport'
        }
    }
}

Describe 'Add-ServiceNowAttachment' {

    It 'uploads a file with the detected content type' {
        Mock -ModuleName ServiceNow.API Invoke-ServiceNowApi { @{ result = @{ sys_id = 'att1' } } }
        Add-ServiceNowAttachment -Table incident -Sys_ID 'abc' -Path $script:TempFile
        Should -Invoke -ModuleName ServiceNow.API Invoke-ServiceNowApi -Times 1 -ParameterFilter {
            $Method -eq 'POST' -and
            $Path -eq 'api/now/attachment/file' -and
            $Query['table_name'] -eq 'incident' -and
            $Query['table_sys_id'] -eq 'abc' -and
            $Query['file_name'] -eq 'sample.txt' -and
            $ContentType -eq 'text/plain' -and
            $InFile -like '*sample.txt'
        }
    }

    It 'returns attachment metadata with -PassThru' {
        Mock -ModuleName ServiceNow.API Invoke-ServiceNowApi { @{ result = @{ sys_id = 'att1' } } }
        $Result = Add-ServiceNowAttachment -Table incident -Sys_ID 'abc' -Path $script:TempFile -PassThru
        $Result.sys_id | Should -Be 'att1'
    }
}

Describe 'Save-ServiceNowAttachment' {

    It 'downloads to a directory using the file name' {
        Mock -ModuleName ServiceNow.API Invoke-ServiceNowApi { }
        Save-ServiceNowAttachment -AttachmentId 'att1' -FileName 'result.txt' -Path $TestDrive
        Should -Invoke -ModuleName ServiceNow.API Invoke-ServiceNowApi -Times 1 -ParameterFilter {
            $Path -eq 'api/now/attachment/att1/file' -and $OutFile -like "*result.txt"
        }
    }
}

Describe 'Remove-ServiceNowAttachment' {

    It 'deletes an attachment by id' {
        Mock -ModuleName ServiceNow.API Invoke-ServiceNowApi { }
        Remove-ServiceNowAttachment -AttachmentId 'att1' -Confirm:$false
        Should -Invoke -ModuleName ServiceNow.API Invoke-ServiceNowApi -Times 1 -ParameterFilter {
            $Method -eq 'DELETE' -and $Path -eq 'api/now/attachment/att1'
        }
    }
}
