Param(
    $Config
)

$serverInstance = $config.ServerInstance

$databasesToCheckConfig = $config.DatabasesToCheck
$databasesToCheckParams = @{
    ServerInstance = $serverInstance
}

if ($databasesToCheckConfig -eq "AGOnly") {
    $databasesToCheckParams.ExcludeLocal = $true

    if ($config.AvailabilityGroup) {
        $databasesToCheckParams.AvailabilityGroup = $config.AvailabilityGroup
    }

}
elseif ($databasesToCheckConfig -eq "LocalOnly") {
    $databasesToCheckParams.ExcludePrimary = $true
}

Describe "No large fixed growth transaction logs" -Tag MaxTLogAutoGrowthInKB {
    $MaxTLogAutoGrowthInKB = $Config.MaxTLogAutoGrowthInKB
    $databases = Get-DatabasesToCheck @databasesToCheckParams
    foreach ($database in $databases) {
        It "$database has no log files with autogrowth greater than $MaxTLogAutoGrowthInKB KB on $serverInstance " {
            @(Get-TLogsWithLargeGrowthSize -Config $Config -Database $database).Count | Should Be 0
        }
    }
}

Describe "Data file space used" -Tag MaxDataFileSize {
    $spaceUsedPercentLimit = $Config.MaxDataFileSize.SpaceUsedPercent

    $databases = Get-DatabasesToCheck @databasesToCheckParams
    foreach ($database in $databases) {
        It "$database files are all under $spaceUsedPercentLimit% full on $serverInstance" {
            @(Get-DatabaseFilesOverMaxDataFileSpaceUsed -Config $Config -Database $database).Count | Should -Be 0
        }
    }
}

Describe "DDL Trigger Presence" -Tag MustHaveDDLTrigger {
    $databasesToCheckParams.ExcludeSystemDatabases = $true
    $databasesToCheckParams.ExcludedDatabases = $Config.MustHaveDDLTrigger.ExcludedDatabases

    $databases = Get-DatabasesToCheck @databasesToCheckParams

    foreach ($database in $databases) {
        It "$database has required DDL triggers on $serverInstance" {
            Get-DatabaseTriggerStatus -Config $Config -Database $database | Should Be $true
        }
    }
}

Describe "Oversized indexes" -Tag CheckForOversizedIndexes {
    $databasesToCheckParams.ExcludedDatabases = $config.CheckForOversizedIndexes.ExcludedDatabases

    $databases = Get-DatabasesToCheck @databasesToCheckParams
    foreach ($database in $databases) {
        It "$database has no oversized indexes on $serverInstance" {
            @(Get-OversizedIndexes -Config $Config -Database $database).Count | Should Be 0
        }
    }
}

Describe "Percentage growth log files" -Tag CheckForPercentageGrowthLogFiles {
    $databases = Get-DatabasesToCheck @databasesToCheckParams
    foreach ($database in $databases) {
        It "$database has no percentage growth log files on $serverInstance" {
            @(Get-TLogWithPercentageGrowth -Config $Config -Database $database).Count | Should Be 0
        }
    }
}

Describe "Last good checkdb" -Tag LastGoodCheckDb {
    $checkDbConfig = $config.LastGoodCheckDb
    $maxDays = $checkDbConfig.MaxDaysSinceLastGoodCheckDB
    [string[]]$excludedDbs = $checkDbConfig.ExcludedDatabases
    $excludedDbs += "tempdb"
    $databasesToCheckParams.ExcludedDatabases = $excludedDbs

    $databases = Get-DatabasesToCheck @databasesToCheckParams
    foreach ($database in $databases) {
        It "$database had a successful CHECKDB in the last $maxDays days on $serverInstance" {
            (Get-DbsWithoutGoodCheckDb -ServerInstance $serverInstance -Database $database).DaysSinceLastGoodCheckDB | Should -BeLessOrEqual $maxDays
        }
    }
}

Describe "Duplicate indexes" -Tag CheckDuplicateIndexes {
    $databasesToCheckParams.ExcludedDatabases = $Config.CheckDuplicateIndexes.ExcludeDatabase

    $databases = Get-DatabasesToCheck @databasesToCheckParams

    foreach ($database in $databases) {
        It "$database has no duplicate indexes on $serverInstance" {
            @(Get-DuplicateIndexes -Config $Config -Database $database).Count | Should Be 0
        }
    }
}

Describe "Zero autogrowth files" -Tag ZeroAutoGrowthFiles {
    $databases = Get-DatabasesToCheck @databasesToCheckParams

    foreach ($database in $databases) {
        It "$database has no zero autogrowth files on $serverInstance" {
            @(Get-FixedSizeFiles -Config $Config -Database $database).Count | Should Be 0
        }
    }
}

Describe "Autogrowth space to grow" -Tag ShouldCheckForAutoGrowthRisks {
    $databases = Get-DatabasesToCheck @databasesToCheckParams

    foreach ($database in $databases) {
        It "$database size-governed filegroups have space for their next growth on $serverInstance" {
            @(Get-AutoGrowthRisks -Config $Config -Database $database).Count | Should Be 0
        }
    }
}
