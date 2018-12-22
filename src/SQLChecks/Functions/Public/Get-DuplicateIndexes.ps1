Function Get-DuplicateIndexes {
    [cmdletbinding()]
    Param(
        [Parameter(ParameterSetName = "Config", ValueFromPipeline = $true, Position = 0)]
        $Config

        , [Parameter(ParameterSetName = "Values")]
        [string]
        $ServerInstance

        , [Parameter(ParameterSetName = "Values")]
        [string[]]
        $ExcludeIndex

        , [string]
        $Database
    )

    if ($PSCmdlet.ParameterSetName -eq "Config") {
        $ServerInstance = $Config.ServerInstance
        $ExcludeIndex = $Config.CheckDuplicateIndexes.ExcludeIndex
    }

    $query = @"
SET LOCK_TIMEOUT 10000;

CREATE TABLE #tempResults
    (
      [InstanceName] sysname ,
      [DatabaseName] sysname ,
      [SchemaName] sysname ,
      [TableName] sysname ,
      [IndexName] sysname ,
      [DuplicateIndexName] sysname
    );

DECLARE @Cmd AS NVARCHAR(MAX)= '';

        SET @Cmd = '
            ;WITH    XMLTable
          AS ( SELECT   OBJECT_NAME(x.object_id) AS [TableName] ,
                        SCHEMA_NAME(o.schema_id) AS SchemaName ,
                        x.object_id ,
                        x.name ,
                        x.index_id ,
                        x.using_xml_index_id ,
                        x.secondary_type ,
                        CONVERT(NVARCHAR(MAX), x.secondary_type_desc) AS secondary_type_desc ,
                        ic.column_id
               FROM     sys.xml_indexes x ( NOLOCK )
                        JOIN sys.dm_db_partition_stats AS s ON x.index_id = s.index_id
                                                              AND x.object_id = s.object_id
                        JOIN sys.objects o ( NOLOCK ) ON x.object_id = o.object_id
                        JOIN sys.index_columns (NOLOCK) ic ON x.object_id = ic.object_id
                                                              AND x.index_id = ic.index_id
               GROUP BY OBJECT_NAME(x.object_id) ,
                        SCHEMA_NAME(o.schema_id) ,
                        x.object_id ,
                        x.name ,
                        x.index_id ,
                        x.using_xml_index_id ,
                        x.secondary_type ,
                        CONVERT(NVARCHAR(MAX), x.secondary_type_desc) ,
                        ic.column_id
             ),
        DuplicatesXMLTable
          AS ( SELECT   x1.SchemaName ,
                        x1.TableName ,
                        x1.name AS IndexName ,
                        x2.name AS DuplicateIndexName ,
                        x1.secondary_type_desc AS IndexType ,
                        x1.index_id ,
                        x1.object_id ,
                        ROW_NUMBER() OVER ( ORDER BY x1.SchemaName, x1.TableName, x1.name, x2.name ) AS seq1 ,
                        ROW_NUMBER() OVER ( ORDER BY x1.SchemaName DESC, x1.TableName DESC, x1.name DESC, x2.name DESC ) AS seq2 ,
                        NULL AS inc
               FROM     XMLTable x1
                        JOIN XMLTable x2 ON x1.object_id = x2.object_id
                                            AND x1.index_id < x2.index_id
                                            AND x1.using_xml_index_id = x2.using_xml_index_id
                                            AND x1.secondary_type = x2.secondary_type
             ),
        IndexColumns
          AS ( SELECT DISTINCT
                        SCHEMA_NAME(o.schema_id) AS [SchemaName] ,
                        OBJECT_NAME(o.object_id) AS TableName ,
                        i.name AS IndexName ,
                        o.object_id ,
                        i.index_id ,
                        i.type ,
                        ( SELECT    CASE key_ordinal
                                      WHEN 0 THEN NULL
                                      ELSE COL_NAME(k.object_id, column_id)
                                           + CASE WHEN is_descending_key = 1
                                                  THEN ''Desc''
                                                  ELSE ''Asc''
                                             END
                                    END AS [data()]
                          FROM      sys.index_columns (NOLOCK) AS k
                          WHERE     k.object_id = i.object_id
                                    AND k.index_id = i.index_id
                          ORDER BY  key_ordinal ,
                                    column_id
                        FOR
                          XML PATH('''')
                        ) AS cols ,
                        CASE WHEN i.index_id = 1
                             THEN ( SELECT  ''['' + name + '']'' AS [data()]
                                    FROM    sys.columns (NOLOCK) AS c
                                    WHERE   c.object_id = i.object_id
                                            AND c.column_id NOT IN (
                                            SELECT  column_id
                                            FROM    sys.index_columns (NOLOCK)
                                                    AS kk
                                            WHERE   kk.object_id = i.object_id
                                                    AND kk.index_id = i.index_id )
                                    ORDER BY column_id
                                  FOR
                                    XML PATH('''')
                                  )
                             ELSE ( SELECT  COL_NAME(k.object_id, column_id) AS [data()]
                                    FROM    sys.index_columns (NOLOCK) AS k
                                    WHERE   k.object_id = i.object_id
                                            AND k.index_id = i.index_id
                                            AND is_included_column = 1
                                            AND k.column_id NOT IN (
                                            SELECT  column_id
                                            FROM    sys.index_columns kk
                                            WHERE   k.object_id = kk.object_id
                                                    AND kk.index_id = 1 )
                                    ORDER BY key_ordinal ,
                                            column_id
                                  FOR
                                    XML PATH('''')
                                  )
                        END AS inc
            ,isnull(i.filter_definition, '''') as FilterDefinition
               FROM     sys.indexes (NOLOCK) AS i
                        INNER JOIN sys.dm_db_partition_stats AS s ON i.index_id = s.index_id
                                                              AND i.object_id = s.object_id
                        INNER JOIN sys.objects o ( NOLOCK ) ON i.object_id = o.object_id
                        INNER JOIN sys.index_columns ic ( NOLOCK ) ON ic.object_id = i.object_id
                                                              AND ic.index_id = i.index_id
                        INNER JOIN sys.columns c ( NOLOCK ) ON c.object_id = ic.object_id
                                                              AND c.column_id = ic.column_id
               WHERE    o.type = ''U''
                        AND i.index_id <> 0
                        AND i.type <> 3
                        AND i.type <> 5
                        AND i.type <> 6
                        AND i.type <> 7
               GROUP BY o.schema_id ,
                        o.object_id ,
                        i.object_id ,
                        i.name ,
                        i.index_id ,
                        i.type,
            i.filter_definition
             ),
        DuplicatesTable
          AS ( SELECT   ic1.SchemaName ,
                        ic1.TableName ,
                        ic1.IndexName ,
                        ic1.object_id ,
                        ic2.IndexName AS DuplicateIndexName,
                        ROW_NUMBER() OVER ( ORDER BY ic1.SchemaName, ic1.TableName, ic1.IndexName, ic2.IndexName ) AS seq1 ,
                        ROW_NUMBER() OVER ( ORDER BY ic1.SchemaName DESC, ic1.TableName DESC, ic1.IndexName DESC, ic2.IndexName DESC ) AS seq2
               FROM     IndexColumns ic1
                        JOIN IndexColumns ic2 ON ic1.object_id = ic2.object_id
                                                 AND ic1.index_id < ic2.index_id
                                                 AND ic1.cols = ic2.cols
                                                 AND ( ISNULL(ic1.inc, '''') = ISNULL(ic2.inc,
                                                              '''')
                                                       OR ic1.index_id = 1
                                                     ) and ic1.FilterDefinition = ic2.FilterDefinition
             )
    SELECT  @@SERVERNAME AS InstanceName ,
            DB_NAME() AS DatabaseName,
            SchemaName ,
            TableName ,
            IndexName ,
            DuplicateIndexName
    FROM    DuplicatesTable dt
    UNION ALL
    SELECT  @@SERVERNAME AS InstanceName ,
            DB_NAME() AS DatabaseName,
            SchemaName ,
            TableName ,
            IndexName ,
            DuplicateIndexName
    FROM    DuplicatesXMLTable dtxml;';

        INSERT  INTO #tempResults
                ( [InstanceName] ,
                  [DatabaseName] ,
                  [SchemaName] ,
                  [TableName] ,
                  [IndexName] ,
                  [DuplicateIndexName]
                )
                EXEC sys.sp_executesql @Cmd;

SELECT  concat_ws('.', tr.DatabaseName, tr.SchemaName, tr.TableName, tr.IndexName) as IndexName
        ,concat_ws('.', tr.DatabaseName, tr.SchemaName, tr.TableName, tr.DuplicateIndexName) as DuplicateIndexName
FROM    #tempResults AS tr;
"@

    Invoke-Sqlcmd -ServerInstance $serverInstance -query $query -QueryTimeout 0 -Database $database | Where-Object {
        $ExcludeIndex -notcontains $_.IndexName -and $ExcludeIndex -notcontains $_.DuplicateIndexName
    } | ForEach-Object {
        [PSCustomObject]@{
            Index          = $_.IndexName
            DuplicateIndex = $_.DuplicateIndexName
        }
    }
}

