Import-Module $PSScriptRoot\..\src\SQLChecks -Force

Function Get-ExpensiveToComputeValue {
  "Non-mocked"
}

Describe "Get-ValueFromCache" {
  Context "Adding and retrieving values" {
    BeforeAll {
      Remove-Variable -Scope Global -Name SQLChecks_Cache -ErrorAction SilentlyContinue
    }
    
    It "lets values be added to the cache and returns them" {
      Get-ValueFromCache -Key "KeyOne" -Value { "ValueOne" } | Should Be "ValueOne"
    }

    It "retrieves values from the cache correctly when called a second time" {
      Get-ValueFromCache -Key "KeyOne" -Value { $null } | Should Be "ValueOne"
    }

    Get-ValueFromCache -Key "KeyTwo" -Value { "ValueTwo" }

    It "retrieves the appropriate values from the cache when multiple items are present" {
      Get-ValueFromCache -Key "KeyOne" -Value { $null } | Should Be "ValueOne"
      Get-ValueFromCache -Key "KeyTwo" -Value { $null } | Should Be "ValueTwo"
    }
  }



  Context "Calls script block the correct number of times " {
    BeforeAll {
      Remove-Variable -Scope Global -Name SQLChecks_Cache -ErrorAction SilentlyContinue
    }

    Mock Get-ExpensiveToComputeValue { return "mocked" }

    Get-ValueFromCache -Key "test" -Value { Get-ExpensiveToComputeValue }
    
    It "calls the function once to populate the cache" {
      Assert-MockCalled -CommandName Get-ExpensiveToComputeValue -Times 1
    }

    Get-ValueFromCache -Key "test" -Value { Get-ExpensiveToComputeValue }
    
    It "doesnt call the function when the value is in the cache" {
      Assert-MockCalled -CommandName Get-ExpensiveToComputeValue -Exactly -Times 1
    }
  }
}