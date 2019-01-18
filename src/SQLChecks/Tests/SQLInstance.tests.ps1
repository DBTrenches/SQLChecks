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

Describe "SQL Alerts" -Tag SQLAlerts {
    It "Alerts are enabled and have alert notification on $serverInstance" {
        @(Get-UnconfiguredAlerts -Config $Config).Count | Should Be 0
    }
}