select  servicename as [Name],IFIEnabled = case when instant_file_initialization_enabled = 'Y' then
                        1 else 0 end
from    sys.dm_server_services
where   servicename like 'SQL Server (%)%';