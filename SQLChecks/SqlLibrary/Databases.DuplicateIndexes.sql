/*
  query ripped and modified very slightly from an MS diagnositics tool
  gets duplicate indexes from the database context within which is it run

  strongly suspect the IndexColumns.cols `for xml path()` aggregation 
  could be replaced with `string_agg()` but not proofing that out at this time. 

  CTEs XMLTable and DuplicatesXMLTable can be removed if 
  `select count(*) from sys.xml_indexes` shows 0 for all databases against which 
  this would be run
*/
set lock_timeout 10000;
set transaction isolation level read uncommitted;

with XMLTable as (
    select
        object_name(x.[object_id]) as TableName,
        schema_name(o.[schema_id]) as SchemaName,
        x.[object_id],
        x.[name],
        x.index_id,
        x.using_xml_index_id,
        x.[secondary_type],
        convert(nvarchar(max), x.secondary_type_desc) as secondary_type_desc,
        ic.column_id
    from sys.xml_indexes as x
    join sys.dm_db_partition_stats as s 
        on x.index_id = s.index_id
        and x.[object_id] = s.[object_id]
    join sys.objects o on x.[object_id] = o.[object_id]
    join sys.index_columns ic 
        on x.[object_id] = ic.[object_id]
        and x.index_id = ic.index_id
    group by 
        object_name(x.[object_id]),
        schema_name(o.[schema_id]),
        x.[object_id],
        x.[name],
        x.index_id,
        x.using_xml_index_id,
        x.[secondary_type],
        convert(nvarchar(max), x.secondary_type_desc),
        ic.column_id
), DuplicatesXMLTable as (
    select
        x1.SchemaName,
        x1.TableName,
        x1.[name] as IndexName,
        x2.[name] as DuplicateIndexName,
        x1.secondary_type_desc as IndexType,
        x1.index_id,
        x1.[object_id],
        row_number() over (order by x1.SchemaName, x1.TableName, x1.[name], x2.[name]) as seq1,
        row_number() over (order by x1.SchemaName desc,
                                    x1.TableName desc,
                                    x1.[name] desc,
                                    x2.[name] desc
                     ) as seq2,
        null as inc
    from XMLTable as x1
    join XMLTable as x2 
        on x1.[object_id] = x2.[object_id]
        and x1.index_id < x2.index_id
        and x1.using_xml_index_id = x2.using_xml_index_id
        and x1.[secondary_type] = x2.[secondary_type]
), IndexColumns as (
    select distinct
        schema_name(o.[schema_id]) as [SchemaName],
        object_name(o.[object_id]) as TableName,
        i.[name] as IndexName,
        o.[object_id],
        i.index_id,
        i.[type],
        cols = (
            select
                iif( 
                    key_ordinal = 0,
                    null, 
                    col_name(
                            k.[object_id],
                            k.column_id
                        ) 
                        + iif(k.is_descending_key=1, 'Desc', 'Asc') 
                ) as [data()]
            from sys.index_columns as k
            where k.[object_id] = i.[object_id]
                and k.index_id = i.index_id
            order by k.key_ordinal, k.column_id
            for xml path('')
        ),
        inc = iif(
                i.index_id = 1, 
                (
                    select quotename(c.[name]) as [data()]
                    from sys.columns as c
                    where c.[object_id] = i.[object_id]
                        and c.column_id not in (
                                select kk.column_id
                                from sys.index_columns as kk
                                where kk.[object_id] = i.[object_id]
                                    and kk.index_id = i.index_id
                            )
                    order by c.column_id
                    for xml path('')
                ), 
                (
                    select col_name(k.[object_id], column_id) as [data()]
                    from sys.index_columns as k
                    where k.[object_id] = i.[object_id]
                        and k.index_id = i.index_id
                        and k.is_included_column = 1
                        and k.column_id not in (
                                select kk.column_id
                                from sys.index_columns as kk
                                where k.[object_id] = kk.[object_id]
                                and kk.index_id = 1
                            )
                    order by k.key_ordinal, k.column_id
                    for xml path('')
                ) 
            ),
        isnull(i.filter_definition, '') as FilterDefinition
    from sys.indexes as i
    inner join sys.dm_db_partition_stats as s 
        on i.index_id = s.index_id
        and i.[object_id] = s.[object_id]
    inner join sys.objects as o on i.[object_id] = o.[object_id]
    inner join sys.index_columns as ic 
        on ic.[object_id] = i.[object_id]
        and ic.index_id = i.index_id
    inner join sys.columns as c 
        on c.[object_id] = ic.[object_id]
        and c.column_id = ic.column_id
    where o.[type] = 'U'
        and i.index_id <> 0
        and i.[type] not in (
            3, -- XML
            5, -- Clustered ColumnStore
            6, -- NonClustered ColumnStore
            7  -- NonClustered hash index
        )
    group by 
        o.[schema_id],
        o.[object_id],
        i.[object_id],
        i.[name],
        i.index_id,
        i.[type],
        i.filter_definition
), DuplicatesTable as (
    select
        ic1.SchemaName,
        ic1.TableName,
        ic1.IndexName,
        ic1.[object_id],
        ic2.IndexName as DuplicateIndexName,
        row_number() over (order by ic1.SchemaName, ic1.TableName, ic1.IndexName, ic2.IndexName) as seq1,
        row_number() over (order by ic1.SchemaName desc,
                                    ic1.TableName desc,
                                    ic1.IndexName desc,
                                    ic2.IndexName desc
                     ) as seq2
    from IndexColumns as ic1
    join IndexColumns as ic2 
        on ic1.[object_id] = ic2.[object_id]
        and ic1.index_id < ic2.index_id
        and ic1.cols = ic2.cols
        and (
            isnull(ic1.inc, '') = isnull(ic2.inc, '')
         or ic1.index_id = 1
        )
        and ic1.FilterDefinition = ic2.FilterDefinition
)
select
    @@servername as InstanceName,
    db_name() as DatabaseName,
    SchemaName,
    TableName,
    IndexName,
    DuplicateIndexName,
    FourPartName = concat(SchemaName,N'.',TableName,N'.',IndexName,N'.',DuplicateIndexName)
from DuplicatesTable as dt
union all
select
    @@servername as InstanceName,
    db_name() as DatabaseName,
    SchemaName,
    TableName,
    IndexName,
    DuplicateIndexName,
    FourPartName = concat(SchemaName,N'.',TableName,N'.',IndexName,N'.',DuplicateIndexName)
from DuplicatesXMLTable as dtxml;
