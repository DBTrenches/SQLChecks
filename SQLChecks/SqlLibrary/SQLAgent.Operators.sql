select
    s.[name] as [Name],
    s.email_address as Email
from msdb.dbo.sysoperators as s
where s.[enabled] = 1;
