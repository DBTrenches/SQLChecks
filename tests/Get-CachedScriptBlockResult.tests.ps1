Import-Module $PSScriptRoot\..\src\SQLChecks -Force

Function Get-ExpensiveToComputeValue {
    "Non-mocked"
}

Describe "Get-CachedScriptBlockResult" {
    Context "adding and retrieving simple values" {
        BeforeAll {
            Remove-SQLChecksCache
        }

        It "lets values be added to the cache and returns them" {
            Get-CachedScriptBlockResult -Key "KeyOne" -ScriptBlock { "ValueOne" } | Should Be "ValueOne"
        }

        It "retrieves values from the cache correctly when called a second time" {
            Get-CachedScriptBlockResult -Key "KeyOne" -ScriptBlock { $null } | Should Be "ValueOne"
        }

        Get-CachedScriptBlockResult -Key "KeyTwo" -ScriptBlock { "ValueTwo" }

        It "retrieves the appropriate values from the cache when multiple items are present" {
            Get-CachedScriptBlockResult -Key "KeyOne" -ScriptBlock { $null } | Should Be "ValueOne"
            Get-CachedScriptBlockResult -Key "KeyTwo" -ScriptBlock { $null } | Should Be "ValueTwo"
        }
    }

    Context "calls script block the correct number of times " {
        BeforeAll {
            Remove-SQLChecksCache
        }

        Mock Get-ExpensiveToComputeValue { return "mocked" }

        Get-CachedScriptBlockResult -Key "test" -ScriptBlock { Get-ExpensiveToComputeValue }
    
        It "calls the function once to populate the cache" {
            Assert-MockCalled -CommandName Get-ExpensiveToComputeValue -Times 1
        }

        Get-CachedScriptBlockResult -Key "test" -ScriptBlock { Get-ExpensiveToComputeValue }
    
        It "doesnt call the function when the value is in the cache" {
            Assert-MockCalled -CommandName Get-ExpensiveToComputeValue -Exactly -Times 1
        }
    }

    Context "adding and retrieving empty values" {
        BeforeAll {
            Remove-SQLChecksCache
        }

        Get-CachedScriptBlockResult -Key "NoProcess" -ScriptBlock {
            Get-Process | Where-Object { $_.ProcessName -eq "does not exist" }
        }

        Mock Get-Process {}

        Get-CachedScriptBlockResult -Key "NoProcess" -ScriptBlock {
            Get-Process | Where-Object { $_.ProcessName -eq "does not exist" }
        }

        It "caches and returns null results" {
            Assert-MockCalled -CommandName Get-Process -Exactly -Times 0
        }
    }
}