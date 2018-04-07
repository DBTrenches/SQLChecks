Function Get-NumberOfErrorLogs {
    [cmdletbinding()]
    Param(
        [string] $ServerInstance
    )

    $query = "declare @NumErrorLogs int;
    exec master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE', N'SOFTWARE\Microsoft\MSSQLServer\MSSQLServer', N'NumErrorLogs', @NumErrorLogs OUTPUT;
    select isnull(@NumErrorLogs, -1) AS [NumberOfErrorLogs];"

    Invoke-Sqlcmd -ServerInstance $serverInstance -query $query | ForEach-Object {
        [pscustomobject]@{
            NumberOfErrorLogs = $_.NumberOfErrorLogs
        }
    }
}