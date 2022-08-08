select
    c.[name] as [Name],
    c.[value] as [Value],
    c.value_in_use as ValueInUse,
    c.is_advanced as IsAdvanced,
    c.[description] as [Description]
from master.sys.configurations as c
where c.[name] in (
    N'clr enabled',
    N'cost threshold for parallelism',
    N'cross db ownership chaining',
    N'Database Mail XPs',
    N'max degree of parallelism',
    N'max server memory (MB)',
    N'optimize for ad hoc workloads',
    N'remote admin connections',
    N'show advanced options',
    N'xp_cmdshell'
);
