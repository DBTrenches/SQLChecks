set lock_timeout 10000;

/*
CREATE TABLE #tempResults
    (
      [InstanceName] sysname ,
      [DatabaseName] sysname ,
      [SchemaName] sysname ,
      [TableName] sysname ,
      [IndexName] sysname ,
      [DuplicateIndexName] sysname
    );
*/
with XMLTable as (
    select
        object_name(x.object_id) as [TableName],
        schema_name(o.schema_id) as SchemaName,
        x.object_id,
        x.name,
        x.index_id,
        x.using_xml_index_id,
        x.secondary_type,
        convert(nvarchar(max), x.secondary_type_desc) as secondary_type_desc,
        ic.column_id
    from sys.xml_indexes x (nolock)
    join sys.dm_db_partition_stats as s on x.index_id = s.index_id
                                       and x.object_id = s.object_id
    join sys.objects o (nolock) on x.object_id = o.object_id
    join sys.index_columns (nolock) ic on x.object_id = ic.object_id
                                      and x.index_id = ic.index_id
    group by object_name(x.object_id),
             schema_name(o.schema_id),
             x.object_id,
             x.name,
             x.index_id,
             x.using_xml_index_id,
             x.secondary_type,
             convert(nvarchar(max), x.secondary_type_desc),
             ic.column_id
), DuplicatesXMLTable as (
    select
        x1.SchemaName,
        x1.TableName,
        x1.name as IndexName,
        x2.name as DuplicateIndexName,
        x1.secondary_type_desc as IndexType,
        x1.index_id,
        x1.object_id,
        row_number() over (order by x1.SchemaName, x1.TableName, x1.name, x2.name) as seq1,
        row_number() over (order by x1.SchemaName desc,
                                    x1.TableName desc,
                                    x1.name desc,
                                    x2.name desc
                     ) as seq2,
        null as inc
    from XMLTable x1
    join XMLTable x2 on x1.object_id = x2.object_id
                    and x1.index_id < x2.index_id
                    and x1.using_xml_index_id = x2.using_xml_index_id
                    and x1.secondary_type = x2.secondary_type
), IndexColumns as (
    select distinct
           schema_name(o.schema_id) as [SchemaName],
           object_name(o.object_id) as TableName,
           i.name as IndexName,
           o.object_id,
           i.index_id,
           i.type,
           (
               select
                   case key_ordinal when 0 then null else
                                                         col_name(
                                                             k.object_id,
                                                             column_id
                                                         )
                                                         + case when is_descending_key = 1 then
                                                                    'Desc' else
                                                                               'Asc' end end as [data()]
               from sys.index_columns (nolock) as k
               where k.object_id = i.object_id
                 and k.index_id = i.index_id
               order by key_ordinal,
                        column_id
               for xml path('')
           ) as cols,
           case when i.index_id = 1 then (
                    select '[' + name + ']' as [data()]
                    from sys.columns (nolock) as c
                    where c.object_id = i.object_id
                      and c.column_id not in (
                              select column_id
                              from sys.index_columns (nolock) as kk
                              where kk.object_id = i.object_id
                                and kk.index_id = i.index_id
                          )
                    order by column_id
                    for xml path('')
                ) else (
               select col_name(k.object_id, column_id) as [data()]
               from sys.index_columns (nolock) as k
               where k.object_id = i.object_id
                 and k.index_id = i.index_id
                 and is_included_column = 1
                 and k.column_id not in (
                         select column_id
                         from sys.index_columns kk
                         where k.object_id = kk.object_id
                           and kk.index_id = 1
                     )
               order by key_ordinal,
                        column_id
               for xml path('')
           ) end as inc,
           isnull(i.filter_definition, '') as FilterDefinition
    from sys.indexes (nolock) as i
    inner join sys.dm_db_partition_stats as s on i.index_id = s.index_id
                                             and i.object_id = s.object_id
    inner join sys.objects o (nolock) on i.object_id = o.object_id
    inner join sys.index_columns ic (nolock) on ic.object_id = i.object_id
                                            and ic.index_id = i.index_id
    inner join sys.columns c (nolock) on c.object_id = ic.object_id
                                     and c.column_id = ic.column_id
    where o.type = 'U'
      and i.index_id <> 0
      and i.type <> 3
      and i.type <> 5
      and i.type <> 6
      and i.type <> 7
    group by o.schema_id,
             o.object_id,
             i.object_id,
             i.name,
             i.index_id,
             i.type,
             i.filter_definition
), DuplicatesTable as (
    select
        ic1.SchemaName,
        ic1.TableName,
        ic1.IndexName,
        ic1.object_id,
        ic2.IndexName as DuplicateIndexName,
        row_number() over (order by ic1.SchemaName, ic1.TableName, ic1.IndexName, ic2.IndexName) as seq1,
        row_number() over (order by ic1.SchemaName desc,
                                    ic1.TableName desc,
                                    ic1.IndexName desc,
                                    ic2.IndexName desc
                     ) as seq2
    from IndexColumns ic1
    join IndexColumns ic2 on ic1.object_id = ic2.object_id
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
    DuplicateIndexName
from DuplicatesTable dt
union all
select
    @@servername as InstanceName,
    db_name() as DatabaseName,
    SchemaName,
    TableName,
    IndexName,
    DuplicateIndexName
from DuplicatesXMLTable as dtxml;
/*
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
*/