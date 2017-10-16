Param(
    $configs
)

Describe "SQL Server Configuration" {
    foreach($config in $configs) {
        $serverInstance = $config.ServerInstance
        Context "Instance level settings" {
            It "$serverInstance has the correct global trace flags set" {
                $traceFlags = $config.TraceFlags
                if($traceFlags -eq $null) {
                    Set-TestInconclusive -Message "No config value found"
                }

                (Test-TraceFlags -ServerInstance $serverInstance -ExpectedFlags $traceFlags).Count | Should Be 0
            }
        }

        Context "Sp_configure settings" {
            $spconfig = $config.SpConfig
            foreach($configProperty in $spconfig.PSObject.Properties) {
                $configName = $configProperty.Name
                $expectedValue = $configProperty.Value

                It "$serverInstance has the correct $configName setting" {               
                    (Test-InstanceSpConfigValue -ServerInstance $serverInstance -ExpectedValue $expectedValue -ConfigName $configName).Count | Should Be 0
                }
            }
        }
    }
}