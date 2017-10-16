Param(
    $configs
)

Describe "SQL Server Configuration" {
    Context "Instance level settings" {
        foreach($config in $configs) {
            $serverInstance = $config.ServerInstance
            
            It "$serverInstance has the correct global trace flags set" {
                $traceFlags = $config.TraceFlags
                if($traceFlags -eq $null) {
                    Set-TestInconclusive -Message "No config value found"
                }

                (Test-TraceFlags -ServerInstance $serverInstance -ExpectedFlags $traceFlags).Count | Should Be 0
            }

            It "$serverInstance has the correct MAXDOP set" {
                $maxdop = $config.InstanceMaxDop
                if($maxdop -eq $null) {
                    Set-TestInconclusive -Message "No config value found"
                }
            
                (Test-InstanceSpConfigValue -ServerInstance $serverInstance -ExpectedValue $maxdop -ConfigName "MaxDegreeOfParallelism").Count | Should Be 0
            }

            It "$serverInstance has the correct xp_cmdshell setting" {
                $cmdshellEnabled = $config.XpCmdshell
                if($cmdshellEnabled -eq $null) {
                    Set-TestInconclusive -Message "No config value found"
                }
            
                (Test-InstanceSpConfigValue -ServerInstance $serverInstance -ExpectedValue $cmdshellEnabled -ConfigName "XpCmdShellEnabled").Count | Should Be 0
            }
        }
    }
}