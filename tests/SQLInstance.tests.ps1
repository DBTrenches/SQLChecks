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
        }
    }

    Context "Sp_configure settings" {
        foreach($config in $configs) {
            $serverInstance = $config.ServerInstance
            $spconfig = $config.SpConfig

            foreach($configProperty in $spconfig.PSObject.Properties) {
                $configName = $configProperty.Name
                $expectedValue = $configProperty.Value

                It "$serverInstance has the correct $configName setting" {               
                    (Get-DbaSpConfigure -Server $serverInstance -ConfigName $configName).RunningValue | Should Be $expectedValue
                }
            }
        }
    }
}