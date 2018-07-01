Import-Module $PSScriptRoot\..\src\SQLChecks -Force

Describe "Import-Module SQLChecks" {
  It "should export at least one function" {
    @(Get-Command -Module SQLChecks).Count | Should BeGreaterThan 0
  }
}