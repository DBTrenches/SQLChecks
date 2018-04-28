Function Get-DatabasesToCheck {
    [cmdletbinding()]
    Param(
        [parameter(Mandatory=$true)][string]$ServerInstance
        ,[string[]]$ExcludedDatabases
        ,[switch]$IncludeSecondary = $false
        ,[switch]$ExcludeSystemDatabases
        ,[switch]$ExcludePrimary = $false
        ,[switch]$ExcludeLocal = $false
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

    if($ExcludeSystemDatabases) {
        $ExcludedDatabases += "master"
        $ExcludedDatabases += "model"
        $ExcludedDatabases += "msdb"
        $ExcludedDatabases += "tempdb"
    }

    Invoke-Sqlcmd -ServerInstance $serverInstance -query $query | Sort-Object -Property DatabaseName | ForEach-Object {       
        if($ExcludedDatabases -contains $_.DatabaseName) {
            return
        }

        if(-not $_.IsAvailabilityGroupDatabase -and -not $ExcludeLocal) {
            $_.DatabaseName
        } elseif ($_.IsPrimaryReplica -and -not $ExcludePrimary) {
            $_.DatabaseName
        } elseif ($_.IsAvailabilityGroupDatabase -and -not $_.IsPrimaryReplica -and $IncludeSecondary) {
            $_.DatabaseName
        }
    }
}