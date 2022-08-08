select
    'tempdb' as DbName,
    count(*) as NumberOfFiles,
    sum(size / 128) as TotalSizeMB
from tempdb.sys.database_files
where [type] = 0;
