
select  dss.status_desc, dss.startup_type_desc
from    sys.dm_server_services as dss
where   dss.servicename like 'SQL Server Agent%';
