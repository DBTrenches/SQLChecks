Function Get-DatabaseServiceBrokerStatus {
    [cmdletbinding()]
    Param(
        [Parameter(ParameterSetName = "Config", ValueFromPipeline = $true, Position = 0)]
        $Config

        , [Parameter(ParameterSetName = "Values")]
        $ServerInstance

        ,[string]
        $Database
    )

    if ($PSCmdlet.ParameterSetName -eq "Config") {
        $ServerInstance = $Config.ServerInstance
    }

    $query = @"
    select  d.is_broker_enabled as IsBrokerEnabled
    from    sys.databases as d
    where   d.name = '$($Database)';
"@

    $result = Invoke-SQLCMD -TrustServerCertificate -ServerInstance $serverInstance -query $query -Database master
    if ($result.IsBrokerEnabled -eq 1) {
        $true
    }
    else {
        $false
    }
}