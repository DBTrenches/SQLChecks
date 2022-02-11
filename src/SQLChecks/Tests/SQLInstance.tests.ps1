Param(
    $Config
)

$serverInstance = $config.ServerInstance

Describe "Trace flags" -Tag TraceFlags {
    It "Correct global trace flags set on $serverInstance" {
        @(Test-TraceFlags $Config).Count | Should Be 0
    }
}

Describe "Number of SQL error logs" -Tag NumErrorLogs {
    It "Correct number of SQL error logs on $serverInstance" {
        $numErrorLogs = $Config.NumErrorLogs

        (Get-NumberOfErrorLogs -Config $Config).NumberOfErrorLogs | Should Be $numErrorLogs
    }
}

Describe "SPConfigure values" -Tag SpConfig {
    $spconfig = $Config.SpConfig

    foreach ($configProperty in $spconfig.PSObject.Properties) {
        $configName = $configProperty.Name
        $expectedValue = $configProperty.Value

        It "Correct sp_configure setting $configName on $serverInstance " {
            (Get-SpConfigValue -Config $Config -ConfigName $configName).ConfiguredValue | Should Be $expectedValue
        }
    }
}

Describe "Startup Extended Events" -Tag StartupXEvents {
    It "has correct set of startup extended event sessions on $serverInstance" {
        @(Test-StartupXEvents -Config $Config).Count | Should Be 0
    }
}

Describe "Database Mail is configured" -Tag DatabaseMail {
    It "Database mail is enabled on $serverInstance" {
        (Get-SpConfigValue -Server $serverInstance -ConfigName "Database Mail XPs").ConfiguredValue | Should Be 1
    }

    It "Database mail has a default profile configured on $serverInstance" {
        @(Get-DefaultDatabaseMailProfile -Config $Config).Count | Should Be 1
    }

    It "Database mail is running on $serverInstance" {
        @(Get-DatabaseMailStatus -Config $Config).Status | Should Be "STARTED"
    }
}

Describe "Sysadmins" -Tag Sysadmins {
    It "Correct list of sysadmins on $serverInstance" {
        (Test-Sysadmins $Config).Count | Should -Be 0
    }
}

Describe "Tempdb Configuration" -Tag TempdbConfiguration {
	
    $NumberOfFiles = $config.TempDBConfiguration.NumberOfFiles
    $TotalSizeMB = $config.TempDBConfiguration.TotalSizeMB
	
    It "Correct number of TempDB files on $serverInstance" {
        (Get-TempDBConfiguration -Config $Config).NumberOfFiles | Should Be $NumberOfFiles
    }

    It "Correct TempDB size on $serverInstance" {
        (Get-TempDBConfiguration -Config $Config).TotalSizeMB | Should Be $TotalSizeMB
    }

}

Describe "Resource Governor Settings" -Tag ResourceGovernorSetting {
    [bool]$IsEnabled = $config.ResourceGovernorSetting.IsEnabled
    $ClassifierFunction = $config.ResourceGovernorSetting.ClassifierFunction

    It "Resource Governor is enabled on $serverInstance" {
        @(Get-ResourceGovernorConfig $Config).IsEnabled | Should Be $IsEnabled
    }
    
    if ($IsEnabled -eq $true) {
        It "Resource Governor classifier function is set correctly on $serverInstance" {
            @(Get-ResourceGovernorConfig $Config).ClassifierFunction | Should Be $ClassifierFunction
        }
    }

    if ($IsEnabled -eq $true) {
        It "Resource Governor classifier function is is not pending reconfiguration on $serverInstance" {
            @(Get-ResourceGovernorConfig $Config).IsReconfigurationPending | Should Be 0
        }
    }
}

Describe "Resource Governor Pool and Workload Group Configuration" -Tag ResourceGovernorPools {
    It "Resource Governor pool/group configuration match template config on $serverInstance" {
        @(Test-ResourceGovernorPoolConfig $Config).Count | Should Be 0
    }
}

Describe "Lock Pages In Memory" -Tag LockPagesInMemoryEnabled {
    $LPIMConfig = $config.LockPagesInMemoryEnabled
    It "Lock Pages In Memory is enabled on $serverInstance" {
        (Get-LockPagesInMemory $Config).LPIMConfig | Should Be $LPIMConfig
    }
}

Describe "SQL Services are set to automatic startup" -Tag SQLServicesStartup {
    It "SQL Engine and Agent services are set to automatic startup on $serverInstance" {
        (Get-AutoStartupSQLServices $Config).Count | Should Be 0
    }
}

Describe "Instant File Initialization Config" -Tag IFIEnabled {
    $IFIConfig = $config.IFIEnabled
    It "Instant File Initialization is enabled on $serverInstance" {
        (Get-InstantFileInitialization $Config).IFIEnabled | Should Be $IFIConfig
    }
}

Describe "SQL Endpoints" -Tag SQLEndpoints {
    It "SQL Endpoints are started on $serverInstance" {
        @(Get-SQLEndpoints $Config).Count | Should Be 0
    }
}

Describe "Unconfigured Managed Backup databases" -Tag UnconfiguredManagedBackups {
    It "Managed Backup is configured on all databases on $serverInstance" {
        @(Get-UnconfiguredManagedBackupDatabases $Config).Count | Should Be 0
    }
}

Describe "Databases with managed backups that are not encrypted" -Tag ManagedBackupDatabasesWithoutEncryption {
    It "Managed Backups are encryted on all databases on $serverInstance" {
        @(Get-ManagedBackupDatabasesWithoutEncryption $Config).Count | Should Be 0
    }
}

Describe "Custom Check - Last good checkdb for secondary replicas" -Tag CustomCheck_LastGoodSecondaryReplicaCheckDb {
    $replicacheckDbConfig = $config.CustomCheck_LastGoodSecondaryReplicaCheckDb
    $maxDays = $replicacheckDbConfig.MaxDaysSinceLastGoodCheckDB
    It "Successful CHECKDB for secondary replicas in the last $maxDays days on $serverInstance" {
        @(Get-SecondaryCheckDBStatus -Config $Config).Count | Should Be 0
    }
}

Describe "Custom Check - Last good full managed backup" -Tag CustomCheck_LastGoodManagedBackup {
    $LastGoodBackupConfig = $config.CustomCheck_LastGoodManagedBackup
    $maxHours = $LastGoodBackupConfig.MaxHoursSinceLastGoodBackup
    It "Successful backup for databases in the last $maxHours hours on $serverInstance" {
        @(Get-DBsWithoutLastGoodManagedBackup -Config $Config).Count | Should Be 0
    }
}

Describe "Custom Check - Last good full backup" -Tag CustomCheck_LastGoodFullBackup {

    $LastGoodBackupConfig = $config.CustomCheck_LastGoodFullBackup
    $DefaultMaxHoursSinceLastBackup = $LastGoodBackupConfig.DefaultMaxHoursSinceLastBackup
    $ExcludedDatabases = $LastGoodBackupConfig.ExcludedDatabases
    $Overrides = $LastGoodBackupConfig.Overrides

    $DBsToCheck = Get-DatabasesToCheck -ServerInstance $serverInstance -IncludeReadOnly -ExcludedDatabases $ExcludedDatabases

    foreach ($DBName in $DBsToCheck) {

        $maxHours = $DefaultMaxHoursSinceLastBackup
        if ($Overrides.Database -contains $DBName){
            $maxHours = ($Overrides | Where-Object {$_.Database -eq $DBName}).MaxHoursSinceLastBackup
        }

        It "Successful full backup on $DBName in the last $maxHours hours on $serverInstance" {
            
            $CompleteHistory = Get-CompleteDBBackupHistory -ServerInstance $serverInstance -DatabaseName $DBName -MaxHours $maxHours
            $FullBackupsFound = @($CompleteHistory | Where-Object { $_.BackupType -eq "Full" })
            $FullBackupsFound.Count | Should BeGreaterThan 0
        }
    }
}

Describe "Custom Check - Last good Ola Diff backup" -Tag CustomCheck_LastGoodDiffOlaBackup {
    $LastGoodBackupConfig = $config.CustomCheck_LastGoodDiffOlaBackup

    foreach ($configItem in $LastGoodBackupConfig) {
        $DBName = $configItem.Database
        $maxHours = $configItem.MaxHoursSinceLastBackup

        It "Successful Ola Diff backup on $DBName in the last $maxHours hours on $serverInstance" {
            
            $CompleteHistory = Get-CompleteDBBackupHistory -ServerInstance $serverInstance -DatabaseName $DBName -MaxHours $maxHours
            $DiffBackupsFound = @($CompleteHistory | Where-Object { $_.BackupType -eq "Diff" })
            $DiffBackupsFound.Count | Should BeGreaterThan 0
        }
    }
}

Describe "Custom Check - Last good Restored Backup Check" -Tag CustomCheck_LastGoodRestoredBackupCheck {

    $lastGoodRestoredBackupCheckConfig = $config.CustomCheck_LastGoodRestoredBackupCheck
    $maxHours = $lastGoodRestoredBackupCheckConfig.MaxHoursSinceLastGoodRestoredBackup
    $databases = $lastGoodRestoredBackupCheckConfig.Databases
    $targetRestoreServer = $lastGoodRestoredBackupCheckConfig.TargetRestoredBackupServer
    foreach ($database in $Databases) {
        $DBName = $database
        
        It "Successful restored backup on $DBName in the last $maxHours hours on $targetRestoreServer" {
            
        $LastRestoredBackup = @(Get-LastRestoredBackup -Config $config -Database $DBName)
        $LastRestoredBackup.Count | Should BeGreaterThan 0
        }
    }
}

Describe "Custom Check - Last good Restored Backup Integrity Check" -Tag CustomCheck_LastGoodIntegrityCheck {

    $lastGoodIntegrityCheckConfig = $config.CustomCheck_LastGoodIntegrityCheck
    $maxHours = $lastGoodIntegrityCheckConfig.MaxHoursSinceLastGoodIntegrityCheck
    $databases = $lastGoodIntegrityCheckConfig.Databases
    $targetRestoreServer = $lastGoodIntegrityCheckConfig.TargetRestoredBackupServer
    foreach ($database in $Databases) {
        $DBName = $database
        
        It "Successful Integrity Check on $DBName in the last $maxHours hours on $targetRestoreServer" {
            
        $LastIntegrityCheck = @(Get-LastIntegrityCheck -Config $config -Database $DBName)
        $LastIntegrityCheck.Count | Should BeGreaterThan 0
        }
    }
}

Describe "Custom Check - Log backups are running" -Tag CustomCheck_RunningLogBackups {

    $DatabasesToCheck = @(Get-ReadWriteDatabases -ServerInstance $serverInstance | Where-Object { $_.RecoveryModel -eq "FULL" })

    foreach ($database in $DatabasesToCheck.DatabaseName) {
        It "Log backups are running for $database database on $serverInstance" {
            
            $CompleteHistory = Get-CompleteDBBackupHistory -ServerInstance $serverInstance -DatabaseName $database -MaxHours 1
            $LogBackupsFound = @($CompleteHistory | Where-Object { $_.BackupType -eq "Log" })
            $LogBackupsFound.Count | Should BeGreaterThan 0
        }
    }
}

Describe "Custom Check - Non Allowed Logins" -Tag CustomCheck_NonAllowedLogins {

    It "Non Allowed logins found on $serverInstance" {
        @(Get-NonAllowedLogins -Config $Config).Count | Should Be 0
    }
}
