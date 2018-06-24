Import-Module $PSScriptRoot\..\src\SQLChecks -Force

Describe "Import-Module SQLChecks" {
  Context "Module Exports" {
    It "Should export at least one function" {
      @(Get-Command -Module SQLChecks).Count | Should BeGreaterThan 0
    }
  }
}