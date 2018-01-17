Param(
    $configs
)

Describe "SQL Server Databases" {
    Context "Per-Database settings" {
        foreach($config in $configs) {
            $serverInstance = $config.ServerInstance
            
            It "$serverInstance has no logs with large fixed autogrowth" {
                $MaxTLogAutoGrowthInKB = $config.MaxTLogAutoGrowthInKB
                if($MaxTLogAutoGrowthInKB  -eq $null) {
                    Set-TestInconclusive -Message "No config value found"
                }
                @(Get-TLogsWithLargeGrowthSize -ServerInstance $serverInstance -GrowthSizeKB $MaxTLogAutoGrowthInKB).Count | Should Be 0
            }
            
            It "$serverInstance has all the required DDL triggers" {
                $MustHaveDDLTrigger = $config.MustHaveDDLTrigger
                if($MustHaveDDLTrigger  -eq $null) {
                    Set-TestInconclusive -Message "No config value found"
                }
                @(Get-DatabasesWithoutDDLTrigger -ServerInstance $serverInstance -TriggerName $MustHaveDDLTrigger).Count | Should Be 0
            }

            It "$serverInstance has all databases under Max DataFile Space Used" {
                $MaxDataFileSpaceUsedPercent = $config.MaxDataFileSpaceUsedPercent
                if($MaxDataFileSpaceUsedPercent  -eq $null) {
                    Set-TestInconclusive -Message "No config value found"
                }
                @(Get-DatabasesOverMaxDataFileSpaceUsed -ServerInstance $serverInstance -MaxDataFileSpaceUsedPercent $MaxDataFileSpaceUsedPercent).Count | Should Be 0
            }

            It "$serverInstance has no oversized indexes" {
                $CheckForOversizedIndexes = $config.CheckForOversizedIndexes
                if($CheckForOversizedIndexes  -eq $null -or -not $CheckForOversizedIndexes) {
                    Set-TestInconclusive -Message "No config value found or check not required"
                }
                @(Get-OversizedIndexes -ServerInstance $serverInstance).Count | Should Be 0
            }

            It "$serverInstance has no percentage growth log files" {
                $CheckForPercentageGrowthLogFiles = $config.CheckForPercentageGrowthLogFiles
                if($CheckForPercentageGrowthLogFiles  -eq $null -or -not $CheckForPercentageGrowthLogFiles) {
                    Set-TestInconclusive -Message "No config value found or check not required"
                }
                @(Get-TLogWithPercentageGrowth -ServerInstance $serverInstance).Count | Should Be 0
            }

            It "$serverInstance has no databases without a recent successful CHECKDB"{
                $MaxDaysAllowedSinceLastGoodCheckDb = $config.MaxDaysAllowedSinceLastGoodCheckDb
                if($MaxDaysAllowedSinceLastGoodCheckDb -eq $null){
                    Set-TestInconclusive -Message "Config value missing for MaxDaysAllowedSinceLastGoodCheckDb"
                }
                @(Get-DbsWithoutGoodCheckDb -ServerInstance $serverInstance -MaxDaysAllowedSinceLastGoodCheckDb $MaxDaysAllowedSinceLastGoodCheckDb).Count | Should Be 0
            }
        }
    }
}