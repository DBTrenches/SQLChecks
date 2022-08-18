/*
https://docs.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/sys-dm-os-sys-info-transact-sql
*/
select 
    osi.committed_kb as CommittedMemoryKb,
    osi.committed_target_kb as CommittedTargetMemoryKb,
    convert(decimal(10,6),osi.committed_kb / power(1024.0,2)) as CommittedMemoryGb,
    convert(decimal(10,6),osi.committed_target_kb / power(1024.0,2)) as CommittedTargetMemoryGb
from sys.dm_os_sys_info as osi;
