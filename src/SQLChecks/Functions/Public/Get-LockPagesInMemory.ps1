Function Get-LockPagesInMemory {
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
    select  locked_page_allocations_kb as LPIMConfig
    from    sys.dm_os_process_memory;
"@

    $result = Invoke-Sqlcmd -ServerInstance $serverInstance -query $query -Database master
    if ($result.LPIMConfig -gt 0) {
        $result.LPIMConfig = 1
    }
    else {
        $result.LPIMConfig = 0
    }

    return $result

}