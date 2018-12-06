Import-Module $PSScriptRoot\..\src\SQLChecks -Force

# Can't mock Invoke-SqlCmd if we're not in module scope - ultimately invoked in a 
# private function (Get-CachedScriptBlockResult)
InModuleScope -ModuleName SQLChecks {
  $standAlone = @(
    ("master", $false, $true, ""),
    ("model", $false, $true, ""),
    ("tempdb", $false, $true, ""),
    ("msdb", $false, $true, "")
  )

  $SQLCHECKS_CACHE_VARIABLE = "SQLChecks_Cache"

  Describe "Get-DatabasesToCheck" {
    BeforeAll {
      Remove-Variable -Scope Global -Name $SQLCHECKS_CACHE_VARIABLE -ErrorAction SilentlyContinue
    }

    Context "Standalone instance" {
      Mock -CommandName Invoke-SqlCmd -MockWith {
        return $standAlone | ForEach-Object {
          [PSCustomObject]@{
            DatabaseName = $_[0]
            IsAvailabilityGroupDatabase = $_[1]
            IsPrimaryReplica = $_[2]
            AvailabilityGroup = $_[3]
          }
        }
      }

      $databases = Get-DatabasesToCheck -ServerInstance "localhost"
      It "Should include all system databases" {
        "master" | Should -BeIn $databases
        "model" | Should -BeIn $databases
        "msdb" | Should -BeIn $databases
        "tempdb" | Should -BeIn $databases
      }

      $databases = Get-DatabasesToCheck -ServerInstance "localhost" -ExcludeSystemDatabases
      It "ExcludeSystemDatabases removes system databases" {
        "master" | Should -Not -BeIn $databases
        "model" | Should -Not -BeIn $databases
        "msdb" | Should -Not -BeIn $databases
        "tempdb" | Should -Not -BeIn $databases
      }
    }
  }
}