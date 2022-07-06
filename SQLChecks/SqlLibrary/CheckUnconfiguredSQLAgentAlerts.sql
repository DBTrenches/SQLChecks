select
    [name],
    [enabled],
    has_notification
from msdb.dbo.sysalerts
where [enabled] = 0
   or has_notification = 0;
