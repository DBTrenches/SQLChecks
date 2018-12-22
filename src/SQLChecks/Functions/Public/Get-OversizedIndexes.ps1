Function Get-OversizedIndexes {
    [cmdletbinding()]
    Param(
        [Parameter(ParameterSetName = "Config", ValueFromPipeline = $true, Position = 0)]
        $Config

        , [Parameter(ParameterSetName = "Values")]
        [string]
        $ServerInstance

        , [string]
        $Database
    )

    if ($PSCmdlet.ParameterSetName -eq "Config") {
        $ServerInstance = $Config.ServerInstance
    }

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


 SET @cmd='

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

SELECT tr.DatabaseName ,
       tr.SchemaName ,
       tr.TableName ,
       tr.IndexName ,
       tr.IndexType ,
       tr.RowLength ,
       tr.ColumnCount FROM #tempResults AS tr;
"@

    Invoke-Sqlcmd -ServerInstance $serverInstance -query $query -Database $Database | ForEach-Object {
        [pscustomobject]@{
            Database    = $_.DatabaseName
            Schema      = $_.SchemaName
            Table       = $_.TableName
            Index       = $_.IndexName
            IndexType   = $_.IndexType
            RowLength   = $_.RowLength
            ColumnCount = $_.ColumnCount
        }
    }
}

