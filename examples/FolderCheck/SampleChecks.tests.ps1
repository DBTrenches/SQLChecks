Param(
    [string]$instanceConfig
)

$config = ConvertFrom-Json $instanceConfig
$serverInstance = $config.ServerInstance

Describe "SQL Instance $serverInstance" {
    It "has the correct global trace flags set" {
        $traceFlags = $config.TraceFlags
        Test-TraceFlags -ServerInstance $serverInstance -ExpectedFlags $traceFlags | Should Be 0
    }
}