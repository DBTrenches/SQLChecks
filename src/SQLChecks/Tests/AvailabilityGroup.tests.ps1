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

## TODO
# Sync secondary count (synchronized) -> all DBs? or foreach DB?
$query = @"
select		adc.database_name
			,drs.synchronization_state_desc
			,drs.redo_queue_size
			,drs.is_primary_replica
from		sys.dm_hadr_database_replica_states as drs
join		sys.availability_groups as ag
on			ag.group_id = drs.group_id
join		sys.availability_databases_cluster as adc
on			adc.group_database_id = drs.group_database_id
where		ag.name = '$availabilityGroup'
"@
Describe "All synchronous commit secondaries are healthy" -Tag AGSyncCommitHealthStatus {
  $results = Invoke-SqlCmd -Query $query -ServerInstance $serverInstance
  # Results has one row per db-replica
  # For each primary DB, there should be N healthy sync-commit replicas
  $primaryDbs = $results | Where-Object { $_.is_primary_replica -eq $true } | Select-Object -ExpandProperty database_name

  foreach($db in $primaryDbs) {
    It "$db has the correct number of healthy sync commit secondaries for $serverInstance" {
      @($results | Where-Object { $_.database_name -eq $db -and $_.synchronization_state_desc -eq "SYNCHRONIZED" -and $_.is_primary_replica -eq $false }).Count | Should -Be 1
    }
  }
}