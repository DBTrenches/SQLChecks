Function Get-OversizedIndexes {
    [cmdletbinding()]
    Param(
        [string] $ServerInstance
    )

    $query = @"
DROP TABLE IF EXISTS #tempresults
CREATE TABLE #tempResults
(
DatabaseName NVARCHAR(100),
SchemaName NVARCHAR(100),
TableName NVARCHAR(100),
IndexName NVARCHAR(100),
IndexType  NVARCHAR(100),
RowLength INT,
ColumnCount TINYINT
)
DECLARE @cmd NVARCHAR(max)

DECLARE dbs CURSOR FOR SELECT d.name FROM sys.databases AS d WHERE d.name NOT IN ('master','tempdb','msdb') AND  ( d.replica_id IS NULL
              OR EXISTS ( SELECT    *
                          FROM      sys.availability_databases_cluster AS adc
                                    JOIN sys.dm_hadr_availability_replica_states
                                    AS dhars ON dhars.group_id = adc.group_id
                          WHERE     dhars.role = 1
                                    AND adc.database_name = d.name )
            )

DECLARE @db AS NVARCHAR(50)

OPEN dbs
FETCH NEXT FROM dbs INTO @db

WHILE @@FETCH_STATUS = 0
BEGIN


 SET @cmd='Use ' + @db + ';
  
SELECT DB_NAME() as DatabaseName,SCHEMA_NAME (o.schema_id) AS ''SchemaName'',o.name AS TableName, i.name AS IndexName, i.type_desc AS IndexType,
sum(max_length) AS RowLength, count (ic.index_id) AS ''ColumnCount''

FROM sys.indexes i (NOLOCK)

INNER JOIN sys.objects o (NOLOCK)  ON i.object_id =o.object_id

INNER JOIN sys.index_columns ic  (NOLOCK) ON ic.object_id =i.object_id and ic.index_id =i.index_id

INNER JOIN sys.columns c  (NOLOCK) ON c.object_id = ic.object_id and c.column_id = ic.column_id

WHERE o.type =''U'' and i.index_id >0 and ic.is_included_column=0

GROUP BY o.schema_id,o.object_id,o.name,i.object_id,i.name,i.index_id,i.type_desc

HAVING (sum(max_length) >CASE WHEN i.type_desc=''NONCLUSTERED'' THEN 1700 ELSE 900 end)

ORDER BY 1,2,3'

 INSERT INTO #tempResults
         ( DatabaseName ,
           SchemaName ,
           TableName ,
           IndexName ,
           IndexType ,
           RowLength ,
           ColumnCount
         )
 EXEC sys.sp_executesql @cmd=@cmd

 FETCH NEXT FROM dbs INTO @db

END

CLOSE dbs
DEALLOCATE dbs

SELECT tr.DatabaseName ,
       tr.SchemaName ,
       tr.TableName ,
       tr.IndexName ,
       tr.IndexType ,
       tr.RowLength ,
       tr.ColumnCount FROM #tempResults AS tr;
"@

    Invoke-Sqlcmd -ServerInstance $serverInstance -query $query
}

