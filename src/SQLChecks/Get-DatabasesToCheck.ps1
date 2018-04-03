Function Get-DatabasesToCheck {
    [cmdletbinding()]
    Param(
        [parameter(Mandatory=$true)][string]$ServerInstance
    )
    # TODO: Allow a switch to specify all/primary only databases

    $query = @"
SELECT  d.name as DatabaseName
        ,case when rs.is_primary_replica = 1 then 1 else 0 end as IsPrimaryReplica
        ,case when rs.database_id is not null then 1 else 0 end as IsAvailabilityGroupDatabase
from sys.databases as d
left join sys.dm_hadr_database_replica_states as rs
on d.database_id = rs.database_id
where d.state_desc = 'ONLINE'
and (rs.database_id is null or (rs.is_local = 1 and rs.is_primary_replica = 1))
"@

    Invoke-Sqlcmd -ServerInstance $serverInstance -query $query | ForEach-Object {
        $_.DatabaseName
    }
}