Function New-ResourceGovernorJSONConfig {
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
declare @RG_JSON nvarchar(max)
    =
        (
            select      rp.name as ResourcePoolName
                       ,wg.name as WorkloadGroupName
                       ,rp.cap_cpu_percent as PoolCapCpuPercent
                       ,rp.min_cpu_percent as PoolMinCpuPercent
                       ,rp.max_cpu_percent as PoolMaxCpuPercent
                       ,rp.min_memory_percent as PoolMinMemoryPercent
                       ,rp.max_memory_percent as PoolMaxMemoryPercent
                       ,wg.request_max_memory_grant_percent as GroupRequestMaxMemoryGrantPercent
                       ,wg.max_dop as GroupMaxDop
            from        sys.dm_resource_governor_workload_groups wg
            join        sys.dm_resource_governor_resource_pools rp
            on          rp.pool_id = wg.pool_id
            order by    wg.name
            for json path, root('ResourceGovernorPools')
        );

select  @RG_JSON as ResourceGovernorOutput;
"@

    $results = Invoke-SQLCMD -TrustServerCertificate -ServerInstance $ServerInstance -query $query -Database master -MaxCharLength 1000000

    return $results.ResourceGovernorOutput


}