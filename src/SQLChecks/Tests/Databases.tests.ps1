Param(
    $Config
)

$serverInstance = $config.ServerInstance

$databasesToCheckConfig = $config.DatabasesToCheck
$databasesToCheckParams = @{
    ServerInstance = $serverInstance
}

if($databasesToCheckConfig -eq "AGOnly") {
    $databasesToCheckParams.ExcludeLocal = $true
} elseif($databasesToCheckConfig -eq "LocalOnly") {
    $databasesToCheckParams.ExcludePrimary = $true
    # Secondary databases are excluded by default
}

Describe "Log File Growth" -Tag MaxTLogAutoGrowthInKB {
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

    $databases = Get-DatabasesToCheck @databasesToCheckParams 

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
    $MustHaveDDLTrigger = $config.MustHaveDDLTrigger
    if($MustHaveDDLTrigger  -eq $null) {
        continue
    }

    $triggerName = $MustHaveDDLTrigger.TriggerName
    $databasesToCheckParams.ExcludeSystemDatabases = $true
    $databasesToCheckParams.ExcludedDatabases = $MustHaveDDLTrigger.ExcludedDatabases

    Context "Testing for presence of DDL Trigger on $serverInstance" {
        $databases = Get-DatabasesToCheck @databasesToCheckParams

        foreach($database in $databases) {
            It "$database has required DDL triggers on $serverInstance" {  
                Get-DatabaseTriggerStatus -ServerInstance $serverInstance -TriggerName $triggerName -Database $database | Should Be $true
            }
        }
    }
}

Describe "Oversized indexes" -Tag CheckForOversizedIndexes {
    Context "Testing for oversied indexes on $serverInstance" {
        $databases = Get-DatabasesToCheck @databasesToCheckParams 
        foreach($database in $databases) {
            It "$database has no oversized indexes on $serverInstance" {
                @(Get-OversizedIndexes -ServerInstance $serverInstance -Database $database).Count | Should Be 0
            }
        }
    }
}

Describe "Percentage growth log files" -Tag CheckForPercentageGrowthLogFiles {
    Context "Testing for no percentage growth log files $serverInstance" {
        $databases = Get-DatabasesToCheck @databasesToCheckParams 
        foreach($database in $databases) {
            It "$database has no percentage growth log files on $serverInstance" {
                @(Get-TLogWithPercentageGrowth -ServerInstance $serverInstance -Database $database).Count | Should Be 0
            }
        }
    }
}

Describe "Last good checkdb" -Tag LastGoodCheckDb {
    $checkDbConfig = $config.LastGoodCheckDb
    $maxDays = $checkDbConfig.MaxDaysSinceLastGoodCheckDB
    $databasesToCheckParams.ExcludedDatabases = $checkDbConfig.ExcludedDatabases

    Context "Testing for last good check db on $serverInstance" {
        $databases = Get-DatabasesToCheck @databasesToCheckParams 
        foreach($database in $databases) {
            if($database -eq "tempdb") {
                continue
            }

            It "$database had a successful CHECKDB in the last $maxDays days on $serverInstance"{
                (Get-DbsWithoutGoodCheckDb -ServerInstance $serverInstance -Database $database).DaysSinceLastGoodCheckDB | Should -BeLessOrEqual $maxDays
            }
        }
    }
}

Describe "Duplicate indexes" -Tag CheckDuplicateIndexes {
    Context "Testing for duplicate indexes on $serverInstance" {
        $CheckDuplicateIndexesConfig = $config.CheckDuplicateIndexes
        $ExcludeDatabase = $CheckDuplicateIndexesConfig.ExcludeDatabase
        $ExcludeIndex = $CheckDuplicateIndexesConfig.ExcludeIndex
        $ExcludeIndexStr  = "'$($ExcludeIndex -join "','")'"

        $databases = Get-DatabasesToCheck @databasesToCheckParams 
        
        foreach($database in $databases) {
            if($ExcludeDatabase -contains $database) {
                continue
            }

            It "$database has no duplicate indexes on $serverInstance" {
                @(Get-DuplicateIndexes -ServerInstance $serverInstance -Database $database -ExcludeIndex $ExcludeIndexStr).Count | Should Be 0
            }
        }
    }
}

Describe "Zero autogrowth files" -Tag ZeroAutoGrowthFiles {
    Context "Testing for zero autogrowth files on $serverInstance" {
        $whitelist = $config.ZeroAutoGrowthFiles.Whitelist
        $databases = Get-DatabasesToCheck @databasesToCheckParams 
        
        foreach($database in $databases) {
            It "$database has no zero autogrowth files on $serverInstance"{
                @(Get-FixedSizeFiles -ServerInstance $serverInstance -WhitelistFiles $whitelist -Database $database).Count | Should Be 0
            }
        }
    }
}

Describe "Autogrowth space to grow" -Tag ShouldCheckForAutoGrowthRisks {
    Context "Testing for autogrowth available space on $serverInstance" {
        $databases = Get-DatabasesToCheck @databasesToCheckParams 

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