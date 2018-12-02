Import-Module $PSScriptRoot\..\src\SQLChecks -Force

Function Get-ExpensiveToComputeValue {
  "Non-mocked"
}

$SQLCHECKS_CACHE_VARIABLE = "SQLChecks_Cache"

Describe "Get-ValueFromCache" {
  Context "adding and retrieving simple values" {
    BeforeAll {
      Remove-Variable -Scope Global -Name $SQLCHECKS_CACHE_VARIABLE -ErrorAction SilentlyContinue
    }
    
    It "lets values be added to the cache and returns them" {
      Get-ValueFromCache -Key "KeyOne" -ScriptBlock { "ValueOne" } | Should Be "ValueOne"
    }

    It "retrieves values from the cache correctly when called a second time" {
      Get-ValueFromCache -Key "KeyOne" -ScriptBlock { $null } | Should Be "ValueOne"
    }

    Get-ValueFromCache -Key "KeyTwo" -ScriptBlock { "ValueTwo" }

    It "retrieves the appropriate values from the cache when multiple items are present" {
      Get-ValueFromCache -Key "KeyOne" -ScriptBlock { $null } | Should Be "ValueOne"
      Get-ValueFromCache -Key "KeyTwo" -ScriptBlock { $null } | Should Be "ValueTwo"
    }
  }

  Context "calls script block the correct number of times " {
    BeforeAll {
      Remove-Variable -Scope Global -Name $SQLCHECKS_CACHE_VARIABLE -ErrorAction SilentlyContinue
    }

    Mock Get-ExpensiveToComputeValue { return "mocked" }

    Get-ValueFromCache -Key "test" -ScriptBlock { Get-ExpensiveToComputeValue }
    
    It "calls the function once to populate the cache" {
      Assert-MockCalled -CommandName Get-ExpensiveToComputeValue -Times 1
    }

    Get-ValueFromCache -Key "test" -ScriptBlock { Get-ExpensiveToComputeValue }
    
    It "doesnt call the function when the value is in the cache" {
      Assert-MockCalled -CommandName Get-ExpensiveToComputeValue -Exactly -Times 1
    }
  }

  Context "adding and retrieving empty values" {
    BeforeAll {
      Remove-Variable -Scope Global -Name $SQLCHECKS_CACHE_VARIABLE -ErrorAction SilentlyContinue
    }

    Get-ValueFromCache -Key "NoProcess" -ScriptBlock {
      Get-Process | Where-Object { $_.ProcessName -eq "does not exist" }
    }

    Mock Get-Process {}

    Get-ValueFromCache -Key "NoProcess" -ScriptBlock {
      Get-Process | Where-Object { $_.ProcessName -eq "does not exist" }
    }

    It "caches and returns null results" {
      Assert-MockCalled -CommandName Get-Process -Exactly -Times 0
    }
  }
}