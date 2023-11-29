Function Get-InstantFileInitialization {
    [cmdletbinding()]
    Param(
        [Parameter(ParameterSetName = "Config", ValueFromPipeline = $true, Position = 0)]
        $Config

        , [Parameter(ParameterSetName = "Values")]
        $ServerInstance
    )

    if ($PSCmdlet.ParameterSetName -eq "Config") {
        $ServerInstance = $Config.ServerInstance
    }

    $query = @"
    select  IFIEnabled = case when instant_file_initialization_enabled = 'Y' then
                              1 else 0 end
    from    sys.dm_server_services
    where   servicename like 'SQL Server (%)%';
"@

    Invoke-SQLCMD -TrustServerCertificate -ServerInstance $serverInstance -query $query -Database master
    
}