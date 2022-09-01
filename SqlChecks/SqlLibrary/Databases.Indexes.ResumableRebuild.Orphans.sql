/* SQL Query for Databases.Indexes.ResumableRebuild.Orphans */
select
    db_name() as DatabaseName,
    s.[name] as SchemaName,
    o.[name] as TableName,
    iro.[name] as IndexName,
    iro.state_desc as [State],
    datediff(minute, iro.last_pause_time, getutcdate()) as PausedTimeInMinutes
from sys.index_resumable_operations as iro
join sys.objects as o on o.[object_id] = iro.[object_id]
join sys.schemas as s on s.[schema_id] = o.[schema_id]
where iro.[state] = 1;
