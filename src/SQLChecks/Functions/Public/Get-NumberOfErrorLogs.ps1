Function Get-NumberOfErrorLogs {
    [cmdletbinding()]
    Param(
        [Parameter(ParameterSetName = "Config", ValueFromPipeline = $true, Position = 0)]
        $Config

        , [Parameter(ParameterSetName = "Values")]
        [string]
        $ServerInstance
    )

    if ($PSCmdlet.ParameterSetName -eq "Config") {
        $ServerInstance = $Config.ServerInstance
    }

    $query = "declare @NumErrorLogs int;
    exec master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE', N'SOFTWARE\Microsoft\MSSQLServer\MSSQLServer', N'NumErrorLogs', @NumErrorLogs OUTPUT;
    select isnull(@NumErrorLogs, -1) AS [NumberOfErrorLogs];"

    Invoke-Sqlcmd -ServerInstance $serverInstance -query $query | ForEach-Object {
        [pscustomobject]@{
            NumberOfErrorLogs = $_.NumberOfErrorLogs
        }
    }
}