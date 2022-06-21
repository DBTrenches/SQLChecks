select [name] as AlertName
from msdb.dbo.sysalerts
where [enabled] = 1
  and has_notification = 1
order by [name];
