
select 
    pp.profile_id as ProfileId,
    pp.principal_sid as PrincipleSid,
    pp.is_default as IsDefault,
    pp.last_mod_datetime as LastModifiedDateTime,
    pp.last_mod_user as LastModifiedBy
from msdb.dbo.sysmail_principalprofile as pp
where pp.principal_sid = 0x0 /* Guest */
  and pp.is_default = 1;
