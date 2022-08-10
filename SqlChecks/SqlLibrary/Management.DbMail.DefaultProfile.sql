
select 
    pp.profile_id as ProfileId,
    pp.principal_sid,
    pp.is_default,
    pp.last_mod_datetime,
    pp.last_mod_user
from msdb.dbo.sysmail_principalprofile as pp
where pp.principal_sid = 0x0 /* Guest */
  and pp.is_default = 1;
