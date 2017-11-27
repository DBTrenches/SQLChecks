Function Get-NumberOfErrorLogs {
    [cmdletbinding()]
    Param(
        [string] $ServerInstance
    )

    $query = "use master
    declare @HkeyLocal nvarchar(18)
    declare @MSSqlServerRegPath nvarchar(31)
    declare @InstanceRegPath sysname
    select @HkeyLocal=N'HKEY_LOCAL_MACHINE'
    select @MSSqlServerRegPath=N'SOFTWARE\Microsoft\MSSQLServer'
    select @InstanceRegPath=@MSSqlServerRegPath + N'\MSSQLServer'
    declare @NumErrorLogs int
    exec master.dbo.xp_instance_regread @HkeyLocal, @InstanceRegPath, N'NumErrorLogs', @NumErrorLogs OUTPUT
    SELECT
    ISNULL(@NumErrorLogs, -1) AS [NumberOfErrorLogs];"

    return (Invoke-Sqlcmd -ServerInstance $serverInstance -query $query).NumberOfErrorLogs 
}