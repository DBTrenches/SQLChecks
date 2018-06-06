Param(
    $Config
)

$serverInstance = $config.ServerInstance

Describe "Trace flags" -Tag TraceFlags {
    Context "Testing for traceflags on $serverInstance" {
        It "Correct global trace flags set on $serverInstance" {
            $traceFlags = $config.TraceFlags
            if($traceFlags -eq $null) {
                Set-TestInconclusive -Message "No config value found"
            }

            @(Test-TraceFlags -ServerInstance $serverInstance -ExpectedFlags $traceFlags).Count | Should Be 0
        }
    }
}

Describe "Number of SQL error logs" -Tag NumErrorLogs {
    Context "Testing for number of SQL error logs on $serverInstance" {
        It "Correct number of SQL error logs on $serverInstance" {
            $numErrorLogs = $config.NumErrorLogs
            if($numErrorLogs  -eq $null) {
                Set-TestInconclusive -Message "No config value found"
            }
            (Get-NumberOfErrorLogs -ServerInstance $serverInstance).NumberOfErrorLogs | Should Be $numErrorLogs
        }
    }
}

Describe "Number of SQL error logs" -Tag SpConfig {
    Context "Testing for SPConfigure values on $serverInstance" {
        $spconfig = $config.SpConfig

        foreach($configProperty in $spconfig.PSObject.Properties) {
            $configName = $configProperty.Name
            $expectedValue = $configProperty.Value

            It "Correct sp_configure setting $configName on $serverInstance " {
                (Get-SpConfigValue -Server $serverInstance -ConfigName $configName).ConfiguredValue | Should Be $expectedValue
            }
        }
    }
}

Describe "Startup Extended Events" -Tag StartupXEvents {
    Context "Testing for startup extended event sessions on $serverInstance" {
        $xeConfig = $config.StartupXEvents
        if($xeConfig -eq $null) {
            continue
        }

        It "Correct set of startup extended event sessions on $serverInstance" {
            @(Test-StartupXEvents -Server $serverInstance -ExpectedSessions $xeConfig).Count | Should Be 0
        }
    }
}

Describe "Database Mail is configured" -Tag DatabaseMail {
    Context "Testing for database mail configuration on $serverInstance" {
        It "Database mail is enabled on $serverInstance" {
            (Get-SpConfigValue -Server $serverInstance -ConfigName "Database Mail XPs").ConfiguredValue | Should Be 1
        }

        It "Database mail has a default profile configured on $serverInstance" {
            @(Get-DefaultDatabaseMailProfile -Server $serverInstance).Count | Should Be 1
        }
    }
}