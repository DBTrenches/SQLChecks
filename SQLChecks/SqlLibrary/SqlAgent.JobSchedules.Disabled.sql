select
    j.job_id as JobId,
    j.[name] as JobName,
    sched.[name] as DisabledScheduleName
from msdb.dbo.sysjobs as j
join msdb.dbo.syscategories as c on j.category_id = c.category_id
cross apply (
    select top 1 s.[name]
    from msdb.dbo.sysjobschedules as js
    join msdb.dbo.sysschedules as s on s.schedule_id = js.schedule_id
    where js.job_id = j.job_id
      and s.[enabled] = 0
) as sched
where c.[name] <> 'Report Server';
