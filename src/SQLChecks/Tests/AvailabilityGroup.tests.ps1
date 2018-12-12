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
  # Results has one row per db-replica
  # For each primary DB, there should be N healthy sync-commit replicas
  #$dbSummary = $results | Where-Object { $_.is_primary_replica -eq $true } | Select-Object -ExpandProperty database_name
  $dbSummary = Get-AGDatabaseSummary $config

  $replicaCount = $config.AGSyncCommitHealthStatus.NumberOfReplicas

  foreach($db in $dbSummary) {
    It "$db has the $replicaCount healthy sync commit secondaries for $availabilityGroup on $serverInstance" {
      #@($results | Where-Object { $_.database_name -eq $db -and $_.synchronization_state_desc -eq "SYNCHRONIZED" -and $_.is_primary_replica -eq $false }).Count | Should -Be 1
      $db.SynchronizedReplicaCount | Should -Be $replicaCount
    }
  }
}