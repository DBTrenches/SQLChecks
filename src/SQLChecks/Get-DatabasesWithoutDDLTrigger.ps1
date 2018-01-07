Function Get-DatabasesWithoutDDLTrigger {
    [cmdletbinding()]
    Param(
        [string] $ServerInstance,
	    [string] $TriggerName
    )

    $query = @"
DROP TABLE IF EXISTS #tempResults

CREATE TABLE #tempResults
(
databaseName NVARCHAR(100)
)

DROP TABLE IF EXISTS #tempDatabases
SELECT d.name 
INTO #tempDatabases
FROM sys.databases d 
WHERE d.name NOT IN ('msdb','master','model','tempdb')
AND (d.REPLICA_id IS NULL OR EXISTS (SELECT * 
FROM sys.availability_databases_cluster AS adc 
JOIN sys.dm_hadr_availability_replica_states AS dhars
ON dhars.group_id = adc.group_id
WHERE dhars.role=1
AND adc.database_name=d.name))

DECLARE Dbs CURSOR FOR 
SELECT name 
FROM #tempDatabases

DECLARE @db NVARCHAR(50)
SET @db = ''
DECLARE @Cmd AS NVARCHAR(max)=''


OPEN Dbs
FETCH NEXT FROM Dbs INTO @db

WHILE @@FETCH_STATUS = 0
BEGIN



SET @Cmd='USE ' + @db +';
IF NOT EXISTS(SELECT * FROM sys.triggers AS t WHERE t.name=''$TriggerName'' and t.is_disabled=0)
and not exists(SELECT * FROM sys.tables AS t where t.is_memory_optimized=1)
select ''' + @db + ''' as databaseName'

INSERT INTO #tempResults
EXEC sys.sp_executesql @Cmd

 FETCH NEXT FROM Dbs INTO @db
END

CLOSE Dbs
DEALLOCATE Dbs


SELECT tr.databaseName FROM #tempResults AS tr;
"@

    Invoke-Sqlcmd -ServerInstance $serverInstance -query $query
}

