Import-Module $PSScriptRoot\..\src\SQLChecks -Force

# Need to mock the internal function Get-AGDatabaseReplicaState
InModuleScope -ModuleName SQLChecks {

  # One primary, one sync secondary - healthy, 2 DBs
  $healthyAG = @(
    ("inst", "healthyAG", "db1", "SYNCHRONIZED", 0, $true),
    ("inst", "healthyAG", "db2", "SYNCHRONIZED", 0, $true),
    ("inst", "healthyAG", "db1", "SYNCHRONIZED", 0, $false),
    ("inst", "healthyAG", "db2", "SYNCHRONIZED", 0, $false)
  )

  $SQLCHECKS_CACHE_VARIABLE = "SQLChecks_Cache"

  Describe "Get-AGDatabaseSummary" {
    BeforeAll {
      Remove-Variable -Scope Global -Name $SQLCHECKS_CACHE_VARIABLE -ErrorAction SilentlyContinue
    }

    Context "HealthyAG" {
      Mock -CommandName Get-AGDatabaseReplicaState -MockWith {
        return $healthyAG | ForEach-Object {
          [PSCustomObject]@{
            ServerInstance = $_[0]
            AvailabilityGroup = $_[1]
            DatabaseName = $_[2]
            SynchronizationState = $_[3]
            RedoQueueSize = $_[4]
            IsPrimaryReplica = $_[5]
          }
        }
      }

      $databases = Get-AGDatabaseSummary -ServerInstance "localhost" -AvailabilityGroup "test"
      
      It "should have two databases in the summary record" {
        $databases.Count | Should -Be 2
      }

      foreach($db in $databases) {
        It "$($db.DatabaseName) should have one synchronized secondary" {
          $db.SynchronizedReplicas | Should -Be 1
        }
      }
    }
  }
}