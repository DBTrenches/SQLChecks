Param(
    $Config
)

$serverInstance = $config.ServerInstance

Describe "Running Services" -Tag RunningServices {

    $ServicesToCheck = $Config.RunningServices

    foreach ($Service in $ServicesToCheck) {
        It "[$Service] service is running on $serverInstance" {
            @(Get-RunningService -Config $Config -ServiceName $Service).Count | Should Be 1
        }

    }
    
}
