declare @NumErrorLogs int;

exec xp_instance_regread
    N'HKEY_LOCAL_MACHINE',
    N'SOFTWARE\Microsoft\MSSQLServer\MSSQLServer',
    N'NumErrorLogs',
    @NumErrorLogs output;

select isnull(@NumErrorLogs, -1) as NumErrorLogs;
