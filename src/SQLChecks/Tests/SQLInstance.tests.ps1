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


