select p.[name] as [Name]
from sys.server_principals as p
join sys.server_role_members as rm 
    on rm.member_principal_id = p.principal_id
join sys.server_principals as sr 
    on sr.principal_id = rm.role_principal_id
    and sr.is_fixed_role = 1
where sr.[name] = 'sysadmin';
