Function Get-DatabasesOverMaxDataFileSpaceUsed {
    [cmdletbinding()]
    Param(
        [string] $ServerInstance,
	    [int] $MaxDataFileSpaceUsedPercent
    )

    $query = @"
CREATE TABLE #tempResults
    (
      [DataBaseName] sysname NOT NULL ,
      [FileName] sysname NOT NULL ,
      [FileGroup] sysname NOT NULL ,
      [UsedSpace] FLOAT
    );

SELECT  d.name
INTO    #tempDatabases
FROM    sys.databases d
WHERE   ( d.replica_id IS NULL
          OR EXISTS ( SELECT    *
                      FROM      sys.availability_databases_cluster AS adc
                                JOIN sys.dm_hadr_availability_replica_states
                                AS dhars ON dhars.group_id = adc.group_id
                      WHERE     dhars.role = 1
                                AND adc.database_name = d.name )
        );


DECLARE Dbs CURSOR
FOR
    SELECT  name
    FROM    #tempDatabases;

DECLARE @db NVARCHAR(50);
SET @db = '';
DECLARE @Cmd AS NVARCHAR(MAX)= '';


OPEN Dbs;
FETCH NEXT FROM Dbs INTO @db;

WHILE @@FETCH_STATUS = 0
    BEGIN



        SET @Cmd = 'USE ' + @db
            + ';
SELECT  DB_NAME() [DataBaseName],
        a.name  [FileName],
        fg.name [FileGroup], 
        (FILEPROPERTY(A.name, ''SPACEUSED'')  /  (A.size * 1.0)  ) * 100 AS [UsedSpace]
FROM    sys.database_files a
        LEFT JOIN sys.filegroups fg ON A.data_space_id = fg.data_space_id
WHERE   A.type != 1;';

        INSERT  INTO #tempResults
                EXEC sys.sp_executesql @Cmd;

        FETCH NEXT FROM Dbs INTO @db;
    END;

CLOSE Dbs;
DEALLOCATE Dbs;


SELECT  distinct tr.DataBaseName
FROM    #tempResults AS tr
WHERE   tr.UsedSpace > $MaxDataFileSpaceUsedPercent;
"@

    Invoke-Sqlcmd -ServerInstance $serverInstance -query $query | ForEach-Object {
        [pscustomobject]@{
            Database = $_.DataBaseName
        }
    }
}

