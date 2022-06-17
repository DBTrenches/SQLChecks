select j.job_id as JobId
    , j.name as JobName
from dbo.sysjobs as j
    join dbo.syscategories as c
    on j.category_id = c.category_id
where c.name <> 'Report Server'
    and not exists (
select 1
    from dbo.sysjobschedules as js
        join dbo.sysschedules as s
        on s.schedule_id = js.schedule_id
    where js.job_id = j.job_id
        and s.enabled = 1
)