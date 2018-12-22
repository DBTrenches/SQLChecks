Function Get-AGDatabaseReplicaState {
    [cmdletbinding()]
    Param(
        [Parameter(Mandatory = $true)]
        $ServerInstance

        , [parameter(Mandatory = $true)]
        [string]
        $AvailabilityGroup
    )

    $query = @"
select  adc.database_name
      ,drs.synchronization_state_desc
      ,drs.redo_queue_size
      ,drs.is_primary_replica
from  sys.dm_hadr_database_replica_states as drs
join  sys.availability_groups as ag
on    ag.group_id = drs.group_id
join  sys.availability_databases_cluster as adc
on    adc.group_database_id = drs.group_database_id
where ag.name = '$availabilityGroup'
"@

    $cacheKey = "AG-$serverInstance-$availabilityGroup"
    $queryResults = Get-CachedScriptBlockResult -Key $cacheKey -ScriptBlock {
        Invoke-Sqlcmd -ServerInstance $ServerInstance -Database master -Query $query -QueryTimeout 60
    }

    $queryResults | ForEach-Object {
        [pscustomobject]@{
            ServerInstance       = $ServerInstance
            AvailabilityGroup    = $AvailabilityGroup
            DatabaseName         = $_.database_name
            SynchronizationState = $_.synchronization_state_desc
            RedoQueueSize        = $_.redo_queue_size
            IsPrimaryReplica     = [bool] $_.is_primary_replica
        }
    }
}