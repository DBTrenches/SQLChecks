Function Test-TLogGrowthSize {
    [cmdletbinding()]
    Param(
        [string] $ServerInstance,
	    [int] $MaxTLogAutoGrowthInKB
    )

    $query = @"
select  d.name as DatabaseName
    ,s.name as FileName
    ,s.growth * 8 as GrowthKB
from    sys.master_files s
join    sys.databases as d
on      s.database_id = d.database_id
where   (
         d.replica_id is null
   or    exists
(
 select  *
 from    sys.availability_databases_cluster as adc
 join    sys.dm_hadr_availability_replica_states as dhars
 on      dhars.group_id = adc.group_id
 where   dhars.role = 1
 and     adc.database_name = d.name
)
     )
and     s.type = 1
and (( s.growth * 8 ) > $MaxTLogAutoGrowthInKB OR s.is_percent_growth =1);
"@

    Invoke-Sqlcmd -ServerInstance $serverInstance -query $query
}



