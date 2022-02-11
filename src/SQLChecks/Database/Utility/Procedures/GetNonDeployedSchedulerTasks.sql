-- depends on https://github.com/DBTrenches/tsqlscheduler/
-- for scheduler.Task

CREATE proc Utility.GetNonDeployedSchedulerTasks
as




declare @AllTasks table (TaskUID uniqueidentifier,
								Identifier nvarchar(128),
								Dbname sysname,
								IsReadWrite bit
								)
declare @SQLAgentTaskJobs table (JobName sysname,
								TaskUID uniqueidentifier)

insert into @SQLAgentTaskJobs
(
    JobName
   ,TaskUID
)
								
select j.name, jobInfo.TaskUid  from msdb.dbo.sysjobs as j
cross apply openjson (j.description, N'$') 
    with (
        InstanceId      uniqueidentifier    N'$.instanceId'
        ,TaskUid        uniqueidentifier    N'$.taskUid'
    ) as jobInfo
where  isjson(j.description) = 1



declare @DBAdminDatabases table (
                                    databaseName nvarchar(128)
									,IsReadWrite bit
                                   ,id int identity(1, 1)
                                );

insert into @DBAdminDatabases (
                              databaseName
							  ,IsReadWrite
                              )
select d.name as DatabaseName, IsReadWrite= case when databasepropertyex(d.name, 'Updateability') = 'READ_WRITE' then 1 else 0 end
from   sys.databases as d
where  d.name like 'DBAdmin%'


declare @baseSql varchar(max)=
'
SELECT t.TaskUid,t.Identifier, ''|DBNAME|'',null FROM |DBNAME|.scheduler.Task  t
where t.IsDeleted = 0 '


declare @i int = 1
       ,@max int = (
                   select max(id)
                   from   @DBAdminDatabases
                   )
       ,@tsql nvarchar(max)
       ,@dbName nvarchar(128);

while @i <= @max
begin
    select @dbName = d.databaseName
    from   @DBAdminDatabases as d
    where  d.id = @i;

    set @tsql = replace(@baseSql, N'|DBNAME|', @dbName);
    --print @tsql
    insert into  @AllTasks
    exec (@tsql);
    set @i += 1;
end;

update a 
set a.IsReadWrite = dad.IsReadWrite
from @AllTasks a
join @DBAdminDatabases dad
on a.Dbname = dad.databaseName


select 'Tasks which have no SQLJobs', * FROM @AllTasks at where at.IsReadWrite = 1 and at.TaskUID not in (SELECT satj.TaskUID FROM @SQLAgentTaskJobs satj)

select 'SQLJobs which have no tasks', *,
'exec msdb.dbo.sp_delete_job  @job_name =''' + satj.JobName + '''' as DropScript
from @SQLAgentTaskJobs satj  
left join @AllTasks at
on at.TaskUID = satj.TaskUID
and satj.JobName = at.Dbname+'-'+ at.Identifier
where at.TaskUID is null


