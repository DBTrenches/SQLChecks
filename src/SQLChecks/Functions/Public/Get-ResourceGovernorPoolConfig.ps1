Function Get-ResourceGovernorPoolConfig {
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
            order by    wg.name;
"@

    $results = Invoke-SQLCMD -TrustServerCertificate -ServerInstance $serverInstance -query $query -Database master 

    $Properties = $results | Get-Member | Where-Object MemberType -eq Property | Sort-Object -Property Name -Descending

    $RGConfigs = @()
    foreach ($result in $results) {
  
        foreach ($property in $Properties) {
            [string]$PropertyName = $property.Name
            $RG += $PropertyName + "="
            $RG += $result.$PropertyName
            $RG += ","
        }        
        $RGConfigs += $RG -replace ".$"
        $RG = ""
    }

    return $RGConfigs
    
}