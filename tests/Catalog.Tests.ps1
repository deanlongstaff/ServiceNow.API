#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
    Pester tests for the Service Catalog cmdlets.
#>

BeforeAll {
    Import-Module "$PSScriptRoot/../src/ServiceNow.API/ServiceNow.API.psd1" -Force
}

Describe 'Get-ServiceNowCatalogItem' {

    It 'searches the catalog with free text' {
        Mock -ModuleName ServiceNow.API Invoke-ServiceNowApi { @{ result = @(@{ sys_id = 'item1' }) } }
        Get-ServiceNowCatalogItem -Query 'laptop'
        Should -Invoke -ModuleName ServiceNow.API Invoke-ServiceNowApi -Times 1 -ParameterFilter {
            $Path -eq 'api/sn_sc/servicecatalog/items' -and $Query['sysparm_text'] -eq 'laptop'
        }
    }

    It 'gets a single catalog item by sys_id' {
        Mock -ModuleName ServiceNow.API Invoke-ServiceNowApi { @{ result = @{ sys_id = 'item1' } } }
        Get-ServiceNowCatalogItem -Sys_ID 'item1'
        Should -Invoke -ModuleName ServiceNow.API Invoke-ServiceNowApi -Times 1 -ParameterFilter {
            $Path -eq 'api/sn_sc/servicecatalog/items/item1'
        }
    }
}

Describe 'Add-ServiceNowCatalogCartItem' {

    It 'adds an item to the cart with a quantity' {
        Mock -ModuleName ServiceNow.API Invoke-ServiceNowApi { @{ result = @{} } }
        Add-ServiceNowCatalogCartItem -Sys_ID 'item1' -Quantity 2
        Should -Invoke -ModuleName ServiceNow.API Invoke-ServiceNowApi -Times 1 -ParameterFilter {
            $Method -eq 'POST' -and
            $Path -eq 'api/sn_sc/servicecatalog/items/item1/add_to_cart' -and
            $Body['sysparm_quantity'] -eq '2'
        }
    }
}

Describe 'Request-ServiceNowCatalogItem' {

    It 'orders an item directly' {
        Mock -ModuleName ServiceNow.API Invoke-ServiceNowApi { @{ result = @{ number = 'REQ001' } } }
        $Result = Request-ServiceNowCatalogItem -Sys_ID 'item1' -Variable @{ requested_for = 'user1' }
        $Result.number | Should -Be 'REQ001'
        Should -Invoke -ModuleName ServiceNow.API Invoke-ServiceNowApi -Times 1 -ParameterFilter {
            $Path -eq 'api/sn_sc/servicecatalog/items/item1/order_now' -and $Body['variables']['requested_for'] -eq 'user1'
        }
    }
}

Describe 'Get-ServiceNowCatalogCart' {

    It 'gets the current cart' {
        Mock -ModuleName ServiceNow.API Invoke-ServiceNowApi { @{ result = @{ cart_items = @() } } }
        Get-ServiceNowCatalogCart
        Should -Invoke -ModuleName ServiceNow.API Invoke-ServiceNowApi -Times 1 -ParameterFilter {
            $Method -eq 'GET' -and $Path -eq 'api/sn_sc/servicecatalog/cart'
        }
    }
}

Describe 'Submit-ServiceNowCatalogCart' {

    It 'submits the cart order' {
        Mock -ModuleName ServiceNow.API Invoke-ServiceNowApi { @{ result = @{ number = 'REQ002' } } }
        $Result = Submit-ServiceNowCatalogCart
        $Result.number | Should -Be 'REQ002'
        Should -Invoke -ModuleName ServiceNow.API Invoke-ServiceNowApi -Times 1 -ParameterFilter {
            $Method -eq 'POST' -and $Path -eq 'api/sn_sc/servicecatalog/cart/submit_order'
        }
    }
}
