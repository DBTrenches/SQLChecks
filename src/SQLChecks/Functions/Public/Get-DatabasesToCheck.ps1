Function Get-DatabasesToCheck {
    [cmdletbinding()]
    Param(
        [parameter(Mandatory=$true)]
        [string]
        $ServerInstance,

        [string[]]
        $ExcludedDatabases,

        [switch]
        $IncludeSecondary = $false,

        [switch]
        $ExcludeSystemDatabases,

        [switch]
        $ExcludePrimary = $false,

        [switch]
        $ExcludeLocal = $false,

        [string]
        $AvailabilityGroup
    )

    $query = @"
select  d.name as DatabaseName
    ,ag.IsAvailabilityGroupDatabase
    ,ag.IsPrimaryReplica
	,grp.name as AvailabilityGroup
from sys.databases as d
left join sys.dm_hadr_database_replica_states as rs
on d.database_id = rs.database_id
and rs.is_local = 1
left join sys.availability_groups as grp
on grp.group_id = rs.group_id
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

    $useCaching = $true

    if($useCaching) {
        Write-Verbose "Get-DatabasesToCheck - Cache is enabled"
        if(-not (Get-Variable -Name GetDatabasesToCheckSQLResultCache -Scope global -ErrorAction SilentlyContinue)) {
            Write-Verbose "Did not find GetDatabasesToCheckSQLResultCache in the global scope"
            Set-Variable -Name GetDatabasesToCheckSQLResultCache -Scope global -Value @{}
        }

        $cache = Get-Variable -Name GetDatabasesToCheckSQLResultCache -Scope global
        if(-not $cache.Value.ContainsKey($serverInstance)) {
            Write-Verbose "Did not find $serverInstance in the cache, populating"
            $results = Invoke-Sqlcmd -ServerInstance $serverInstance -query $query -QueryTimeout 60
            $cache.Value[$serverInstance] = $results
        } else {
            Write-Verbose "Found $serverInstance in the cache"
            $results = $cache.Value[$serverInstance]
        }

        $queryResults = $results
    } else {
        $queryResults = Invoke-Sqlcmd -ServerInstance $serverInstance -query $query -QueryTimeout 60
    }

    $queryResults | Sort-Object -Property DatabaseName | ForEach-Object {
        if($ExcludedDatabases -contains $_.DatabaseName) {
            return
        }

        # If an AG is specified only process databases in this AG
        if($AvailabilityGroup -ne "" -and $_.AvailabilityGroup -ne $AvailabilityGroup) {
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