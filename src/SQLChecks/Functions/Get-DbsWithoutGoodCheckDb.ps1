Function Get-DbsWithoutGoodCheckDb{
    [cmdletbinding()]Param(
        [parameter(Mandatory=$true)][string]$ServerInstance
        ,[parameter(Mandatory=$true)][string]$Database
    )

    $query = @"
drop table if exists #DBInfo;
create table #DBInfo 
(
    ParentObject varchar(255)
    ,[Object] varchar(255)
    ,Field varchar(255)
    ,[Value] varchar(255)
);

insert #DBInfo
execute('dbcc dbinfo() with tableresults');

select  try_cast(dbi.[Value] as datetime) as LastGoodCheckDbDate
        ,coalesce(datediff(day, try_cast(dbi.[Value] as datetime), getutcdate()),9999) as DaysSinceLastGoodCheckDb
from    #DBInfo as dbi
where   dbi.Field = 'dbi_dbccLastKnownGood'
"@
    Invoke-Sqlcmd -ServerInstance $serverInstance -query $query -Database $database | ForEach-Object {
        [pscustomobject]@{
            Database = $database
            LastGoodCheckDb = $_.LastGoodCheckDbDate
            DaysSinceLastGoodCheckDB = $_.DaysSinceLastGoodCheckDb
        }
    }
}