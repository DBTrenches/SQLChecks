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
                $checkDbConfig = $config.LastGoodCheckDb
                if($checkDbConfig -eq $null -or -not $checkDbConfig.Check){
                    Set-TestInconclusive -Message "No config value found or check not required"
                }

                $maxDays = $checkDbConfig.MaxDaysSinceLastGoodCheckDB
                $excludedDbs = $checkDbConfig.ExcludedDatabases

                @(Get-DbsWithoutGoodCheckDb -ServerInstance $serverInstance -MaxDaysAllowedSinceLastGoodCheckDb $maxDays -ExcludedDatabases $excludedDbs).Count | Should Be 0
            }

            It "$serverInstance has no duplicate indexes" {
                $CheckDuplicateIndexesConfig = $config.CheckDuplicateIndexes
                $ExcludeDatabase = $CheckDuplicateIndexesConfig.ExcludeDatabase
                $ExcludeIndex = $CheckDuplicateIndexesConfig.ExcludeIndex
                $ExcludeDatabaseStr  = "'$($ExcludeDatabase -join "','")'"
                $ExcludeIndexStr  = "'$($ExcludeIndex -join "','")'"
               
                if($CheckDuplicateIndexesConfig  -eq $null -or -not $CheckDuplicateIndexesConfig.Check) {
                    Set-TestInconclusive -Message "No config value found or check not required"
                }
                @(Get-DuplicateIndexes -ServerInstance $serverInstance -ExcludeDatabase $ExcludeDatabaseStr -ExcludeIndex $ExcludeIndexStr).Count | Should Be 0
            }

            It "$serverInstance has no zero-autogrowth files outside whitelist"{
                $configValue = $config.ZeroAutoGrowthFiles
                
                if($configValue -eq $null -or -not $configValue.Check) {
                    Set-TestInconclusive -Message "No config value found or check not required"
                }
                @(Get-FixedSizeFiles -ServerInstance $serverInstance -WhitelistFiles $configValue.Whitelist).Count | Should Be 0
            }

            It "$serverInstance - all size-governed filegroups have sufficent space for their next growth" {
                $shouldCheck = $config.ShouldCheckForAutoGrowthRisks
                
                if($shouldCheck -eq $null -or -not $shouldCheck) {
                    Set-TestInconclusive -Message "No config value found or check not required"
                }

                @(Get-AutoGrowthRisks -ServerInstance $serverInstance ).Count | Should Be 0
            }
        }
    }
}