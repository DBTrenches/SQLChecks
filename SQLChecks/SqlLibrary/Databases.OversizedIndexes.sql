
-- don't run this in tempdb w/o uncommitted
set transaction isolation level read uncommitted;

select
    FourPartName = concat(
        db_name(),N'.',
        schema_name(o.[schema_id]),N'.',
        o.[name],N'.',
        i.[name]
    ),
    db_name() as DatabaseName,
    schema_name(o.[schema_id]) as [SchemaName],
    o.[name] as TableName,
    i.[name] as IndexName,
    i.[type_desc] as IndexType,
    sum(c.max_length) as RowLength,
    count(ic.index_id) as [ColumnCount]
from sys.indexes as i 
join sys.objects as o on i.[object_id] = o.[object_id]
join sys.index_columns as ic 
    on ic.[object_id] = i.[object_id]
    and ic.index_id = i.index_id
join sys.columns as c 
    on c.[object_id] = ic.[object_id]
    and c.column_id = ic.column_id
where o.[type] = 'U'
  and i.index_id > 0
  and ic.is_included_column = 0
group by 
    o.[schema_id],
    o.[object_id],
    o.[name],
    i.[object_id],
    i.[name],
    i.index_id,
    i.[type_desc]
having sum(c.max_length) > iif(i.[type_desc] = 'NONCLUSTERED', 1700, 900);
