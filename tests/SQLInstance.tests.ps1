Param(
    $configs
)

Describe "SQL Server Configuration" {
    Context "Instance level settings" {
        foreach($config in $configs) {
            $serverInstance = $config.ServerInstance
            $traceFlags = $config.TraceFlags
            It "$serverInstance has the correct global trace flags set" {
                (Test-TraceFlags -ServerInstance $serverInstance -ExpectedFlags $traceFlags).Count | Should Be 0
            }

            $maxdop = $config.InstanceMaxDop
            It "$serverInstance has the correct MAXDOP set" {
                (Test-InstanceMaxDop -ServerInstance $serverInstance -ExpectedValue $maxdop).Count | Should Be 0
            }
        }
    }
}