Param(
    $configs
)

Describe "SQL Server Databases" {
    Context "Per-Database settings" {
        foreach($config in $configs) {
            $serverInstance = $config.ServerInstance
            
            It "$serverInstance has the all TLogs complying Max Auto Growth" {
                $MaxTLogAutoGrowthInKB = $config.MaxTLogAutoGrowthInKB
                if($MaxTLogAutoGrowthInKB  -eq $null) {
                    Set-TestInconclusive -Message "No config value found"
                }
                (Test-TLogGrowthSize -ServerInstance $serverInstance -MaxTLogAutoGrowthInKB $MaxTLogAutoGrowthInKB).Count | Should Be 0
            }
            
            It "$serverInstance has all the required DDL triggers" {
                $MustHaveDDLTrigger = $config.MustHaveDDLTrigger
                if($MustHaveDDLTrigger  -eq $null) {
                    Set-TestInconclusive -Message "No config value found"
                }
                (Get-DatabasesWithoutDDLTrigger -ServerInstance $serverInstance -TriggerName $MustHaveDDLTrigger).Count | Should Be 0
            }

            It "$serverInstance has no oversized indexes" {
                $CheckForOversizedIndexes = $config.CheckForOversizedIndexes
                if($CheckForOversizedIndexes  -eq $null -or -not $CheckForOversizedIndexes) {
                    Set-TestInconclusive -Message "No config value found or check not required"
                }
                (Get-OversizedIndexes -ServerInstance $serverInstance).Count | Should Be 0
            }
        }
    }
}