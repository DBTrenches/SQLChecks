declare @num_days tinyint = 7;

select 
    db=d.[name]
from sys.databases d
outer apply ( 
    select top(1) * 
    from dbo.CommandLog cl
    where cl.DatabaseName = d.[name] collate database_default
        and cl.CommandType = N'DBCC_CHECKDB'
        and cl.ErrorNumber = 0 
        and cl.EndTime is not null
    order by cl.id desc 
) mrd -- most recent dbcc
where (mrd.StartTime < dateadd(day,(-1 * @num_days),getdate()) or mrd.StartTime is null);
