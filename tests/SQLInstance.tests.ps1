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
            
                (Test-InstanceMaxDop -ServerInstance $serverInstance -ExpectedValue $maxdop).Count | Should Be 0
            }
        }
    }
}