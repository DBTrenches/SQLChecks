Param(
    $configs
)

Describe "Log File Growth" -Tag MaxTLogAutoGrowthInKB {
    foreach($config in $configs) {
        $serverInstance = $config.ServerInstance
        Context "Testing no large fixed autogrowth on $serverInstance" {
            It "No logs with large fixed autogrowth on $serverInstance " {
                $MaxTLogAutoGrowthInKB = $config.MaxTLogAutoGrowthInKB
                if($MaxTLogAutoGrowthInKB  -eq $null) {
                    Set-TestInconclusive -Message "No config value found"
                }
                @(Get-TLogsWithLargeGrowthSize -ServerInstance $serverInstance -GrowthSizeKB $MaxTLogAutoGrowthInKB).Count | Should Be 0
            }
        }
    }
}

Describe "Data file space used" -Tag MaxDataFileSpaceUsedPercent {
    foreach($config in $configs) {
        $serverInstance = $config.ServerInstance
        Context "Testing for data file space usage on $serverInstance" {
            It "All databases under Max DataFile Space Used on $serverInstance" {
                $MaxDataFileSpaceUsedPercent = $config.MaxDataFileSpaceUsedPercent
                if($MaxDataFileSpaceUsedPercent  -eq $null) {
            It "$serverInstance has all databases under Max DataFile Space Used" {
                $MaxDataFileSize=$config.MaxDataFileSize
                
                if(($MaxDataFileSize -eq $null) -or ($MaxDataFileSize.Check -eq $false)) {
                  Set-TestInconclusive -Message "No config value found"
                }
                $MaxDataFileParams=@{
                    ServerInstance=$serverInstance
                    MaxDataFileSpaceUsedPercent=$MaxDataFileSize.SpaceUsedPercent
                    WhiteListFiles = "'$($MaxDataFileSize.WhitelistFiles -join "','")'"
                }
                
                @(Get-DatabasesOverMaxDataFileSpaceUsed @MaxDataFileParams).Count | Should Be 0
            }
        }
    }
}

Describe "DDL Trigger Presence" -Tag MustHaveDDLTrigger {
    foreach($config in $configs) {
        $serverInstance = $config.ServerInstance
        $MustHaveDDLTrigger = $config.MustHaveDDLTrigger
        if($MustHaveDDLTrigger  -eq $null) {
            continue
        }

        $triggerName = $MustHaveDDLTrigger.TriggerName
        $excludedDatabases = $MustHaveDDLTrigger.ExcludedDatabases

        Context "Testing for presence of DDL Trigger on $serverInstance" {
            $databases = Get-DatabasesToCheck -ServerInstance $serverInstance -PrimaryOnly -ExcludeSystemDatabases

            foreach($database in $databases) {
                if($excludedDatabases -contains $database) {
                    continue
                }
                It "$database has required DDL triggers on $serverInstance" {  
                    Get-DatabaseTriggerStatus -ServerInstance $serverInstance -TriggerName $triggerName -Database $database | Should Be $true
                }
            }
        }
    }
}

Describe "Oversized indexes" -Tag CheckForOversizedIndexes {
    foreach($config in $configs) {
        $serverInstance = $config.ServerInstance
        Context "Testing for oversied indexes on $serverInstance" {
            It "No oversized indexes on $serverInstance" {
                $CheckForOversizedIndexes = $config.CheckForOversizedIndexes
                if($CheckForOversizedIndexes  -eq $null -or -not $CheckForOversizedIndexes) {
                    Set-TestInconclusive -Message "No config value found or check not required"
                }
                @(Get-OversizedIndexes -ServerInstance $serverInstance).Count | Should Be 0
            }
        }
    }
}

Describe "Percentage growth log files" -Tag CheckForPercentageGrowthLogFiles {
    foreach($config in $configs) {
        $serverInstance = $config.ServerInstance
        Context "Testing for no percentage growth log files $serverInstance" {
            It "No percentage growth log files on $serverInstance" {
                $CheckForPercentageGrowthLogFiles = $config.CheckForPercentageGrowthLogFiles
                if($CheckForPercentageGrowthLogFiles  -eq $null -or -not $CheckForPercentageGrowthLogFiles) {
                    Set-TestInconclusive -Message "No config value found or check not required"
                }
                @(Get-TLogWithPercentageGrowth -ServerInstance $serverInstance).Count | Should Be 0
            }
        }
    }
}

Describe "Last good checkdb" -Tag LastGoodCheckDb {
    foreach($config in $configs) {
        $serverInstance = $config.ServerInstance
        Context "Testing for last good check db on $serverInstance" {
            It "No databases without a recent successful CHECKDB on $serverInstance"{
                $checkDbConfig = $config.LastGoodCheckDb
                if($checkDbConfig -eq $null -or -not $checkDbConfig.Check){
                    Set-TestInconclusive -Message "No config value found or check not required"
                }

                $maxDays = $checkDbConfig.MaxDaysSinceLastGoodCheckDB
                $excludedDbs = $checkDbConfig.ExcludedDatabases

                @(Get-DbsWithoutGoodCheckDb -ServerInstance $serverInstance -MaxDaysAllowedSinceLastGoodCheckDb $maxDays -ExcludedDatabases $excludedDbs).Count | Should Be 0
            }
        }
    }
}

Describe "Duplicate indexes" -Tag CheckDuplicateIndexes {
    foreach($config in $configs) {
        $serverInstance = $config.ServerInstance
        Context "Testing for duplicatge indexes on $serverInstance" {
            It "No duplicate indexes on $serverInstance" {
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
        }
    }
}

Describe "Zero autogrowth files" -Tag ZeroAutoGrowthFiles {
    foreach($config in $configs) {
        $serverInstance = $config.ServerInstance
        Context "Testing for zero autogrowth files on $serverInstance" {
            It "No zero-autogrowth files outside whitelist on $serverInstance"{
                $configValue = $config.ZeroAutoGrowthFiles
                
                if($configValue -eq $null -or -not $configValue.Check) {
                    Set-TestInconclusive -Message "No config value found or check not required"
                }
                @(Get-FixedSizeFiles -ServerInstance $serverInstance -WhitelistFiles $configValue.Whitelist).Count | Should Be 0
            }
        }
    }
}

Describe "Autogrowth space to grow" -Tag ShouldCheckForAutoGrowthRisks {
    foreach($config in $configs) {
        $serverInstance = $config.ServerInstance
        Context "Testing for autogrowth available space on $serverInstance" {
            $databases = Get-DatabasesToCheck -ServerInstance $serverInstance -PrimaryOnly

            foreach($database in $databases) {
                It "$database size-governed filegroups have space for their next growth on $serverInstance" {
                    $shouldCheck = $config.ShouldCheckForAutoGrowthRisks
                    if($shouldCheck -eq $null -or -not $shouldCheck) {
                        Set-TestInconclusive -Message "No config value found or check not required"
                    }
            
                    @(Get-AutoGrowthRisks -ServerInstance $serverInstance -Database $database).Count | Should Be 0
                }
            }
        }
    }
}