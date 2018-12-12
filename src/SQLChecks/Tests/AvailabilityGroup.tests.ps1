Param(
  $Config
)

$serverInstance = $config.ServerInstance
$availabilityGroup = $config.AvailabilityGroup

Describe "AG Instance connectivity" -Tag AGInstanceConnectivity {
  It "Can connect to $serverInstance" {
    {
      Invoke-SqlCmd -ServerInstance $serverInstance -Query "select @@servername" -Database master
    } | Should -Not -Throw
  }
}

Describe "All synchronous commit secondaries are healthy" -Tag AGSyncCommitHealthStatus {
  $dbSummary = Get-AGDatabaseSummary $config

  $replicaCount = $config.AGSyncCommitHealthStatus.NumberOfReplicas

  foreach($db in $dbSummary) {
    It "$($db.DatabaseName) has $replicaCount healthy sync commit secondaries for $availabilityGroup on $serverInstance" {
      $db.SynchronizedReplicas | Should -Be $replicaCount
    }
  }
}