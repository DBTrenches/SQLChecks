Param(
    $Config
)

Describe "Log File Growth" -Tag MaxTLogAutoGrowthInKB {
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

Describe "Data file space used" -Tag MaxDataFileSize {
    $serverInstance = $config.ServerInstance
    $maxDataConfig = $config.MaxDataFileSize
    if($maxDataConfig  -eq $null) {
        continue
    }
    
    $spaceUsedPercentLimit = $maxDataConfig.SpaceUsedPercent
    $MaxDataFileParams=@{
        ServerInstance = $serverInstance
        MaxDataFileSpaceUsedPercent = $spaceUsedPercentLimit
        WhiteListFiles = $maxDataConfig.WhitelistFiles
    }

    $databases = Get-DatabasesToCheck -ServerInstance $serverInstance -PrimaryOnly

    Context "Testing for data file space usage on $serverInstance" {
        foreach($database in $databases) {
            It "$database files are all under $spaceUsedPercentLimit% full on $serverInstance" {
                $MaxDataFileParams.Database = $database
                @(Get-DatabaseFilesOverMaxDataFileSpaceUsed @MaxDataFileParams).Count | Should -Be 0
            }
        }
    }
}

Describe "DDL Trigger Presence" -Tag MustHaveDDLTrigger {
    $serverInstance = $config.ServerInstance
    $MustHaveDDLTrigger = $config.MustHaveDDLTrigger
    if($MustHaveDDLTrigger  -eq $null) {
        continue
    }

    $triggerName = $MustHaveDDLTrigger.TriggerName
    $excludedDatabases = $MustHaveDDLTrigger.ExcludedDatabases

    Context "Testing for presence of DDL Trigger on $serverInstance" {
        $databases = Get-DatabasesToCheck -ServerInstance $serverInstance -PrimaryOnly -ExcludeSystemDatabases -ExcludedDatabases $excludedDatabases

        foreach($database in $databases) {
            It "$database has required DDL triggers on $serverInstance" {  
                Get-DatabaseTriggerStatus -ServerInstance $serverInstance -TriggerName $triggerName -Database $database | Should Be $true
            }
        }
    }
}

Describe "Oversized indexes" -Tag CheckForOversizedIndexes {
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

Describe "Percentage growth log files" -Tag CheckForPercentageGrowthLogFiles {
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

Describe "Last good checkdb" -Tag LastGoodCheckDb {
    $serverInstance = $config.ServerInstance
    $checkDbConfig = $config.LastGoodCheckDb
    $maxDays = $checkDbConfig.MaxDaysSinceLastGoodCheckDB
    $excludedDbs = $checkDbConfig.ExcludedDatabases

    Context "Testing for last good check db on $serverInstance" {
        $databases = Get-DatabasesToCheck -ServerInstance $serverInstance -PrimaryOnly
        foreach($database in $databases) {
            if($excludedDbs -contains $database -or $database -eq "tempdb") {
                continue
            }

            It "$database had a successful CHECKDB in the last $maxDays days on $serverInstance"{
                (Get-DbsWithoutGoodCheckDb -ServerInstance $serverInstance -Database $database).DaysSinceLastGoodCheckDB | Should -BeLessOrEqual $maxDays
            }
        }
    }
}

Describe "Duplicate indexes" -Tag CheckDuplicateIndexes {
    $serverInstance = $config.ServerInstance
    Context "Testing for duplicate indexes on $serverInstance" {
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

Describe "Zero autogrowth files" -Tag ZeroAutoGrowthFiles {
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

Describe "Autogrowth space to grow" -Tag ShouldCheckForAutoGrowthRisks {
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