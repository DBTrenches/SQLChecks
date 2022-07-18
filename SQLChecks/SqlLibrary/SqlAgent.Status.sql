
select  
    dss.status_desc as StatusDescription, 
    dss.startup_type_desc as StartupTypeDescription
from    msdb.sys.dm_server_services as dss
where   dss.servicename like 'SQL Server Agent%';
