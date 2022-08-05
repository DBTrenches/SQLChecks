select
    a.[name] as [FileName],
    fg.[name] as [FileGroup],
    c.SpaceUsed,
    c.SpaceUsedByMaxSize,
    concat(db_name(),N'.',a.[name]) as DBFile
from sys.database_files as a
left join sys.filegroups as fg on a.data_space_id = fg.data_space_id
cross apply (
    select 
        SpaceUsed = (fileproperty(a.[name], 'SPACEUSED') / (a.size * 1.0)) * 100,
        SpaceUsedByMaxSize = isnull((fileproperty(a.[name], 'SPACEUSED') / (nullif(a.max_size,-1) * 1.0)) * 100, 0.00)
) as c
where a.[type] != 1; -- log
