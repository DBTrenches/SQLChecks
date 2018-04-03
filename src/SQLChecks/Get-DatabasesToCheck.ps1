Function Get-DatabasesToCheck {
    [cmdletbinding()]
    Param(
        [parameter(Mandatory=$true)][string]$ServerInstance
        ,[switch]$PrimaryOnly
    )

    $query = @"
SELECT  d.name as DatabaseName
    ,ag.IsAvailabilityGroupDatabase
    ,ag.IsPrimaryReplica
from sys.databases as d
left join sys.dm_hadr_database_replica_states as rs
on d.database_id = rs.database_id
and rs.is_local = 1
outer apply (
select  case when rs.database_id is null then 0 else 1 end as IsAvailabilityGroupDatabase
        ,case when rs.is_primary_replica = 1 then 1 else 0 end as IsPrimaryReplica
) as ag
where d.state_desc = 'ONLINE'
"@

    Invoke-Sqlcmd -ServerInstance $serverInstance -query $query | Sort-Object -Property DatabaseName | ForEach-Object {
        if(-not $PrimaryOnly)
        {
            $_.DatabaseName
        } elseif($_.IsPrimaryReplica -or -not $_.IsAvailabilityGroupDatabase) {
            $_.DatabaseName
        }
    }
}