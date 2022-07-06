select
    s.[name] as OperatorName,
    s.email_address as OperatorEmail
from msdb.dbo.sysoperators as s
where s.[enabled] = 1;
