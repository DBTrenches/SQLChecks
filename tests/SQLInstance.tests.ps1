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
            
            It "$serverInstance has the correct number of error logs" {
                $numErrorLogs = $config.NumErrorLogs
                if($numErrorLogs  -eq $null) {
                    Set-TestInconclusive -Message "No config value found"
                }
                Get-NumberOfErrorLogs -ServerInstance $serverInstance | Should Be $numErrorLogs
            }

            It "$serverInstance has the all TLogs complying Max Auto Growth" {
                $MaxTLogAutoGrowthInKB = $config.MaxTLogAutoGrowthInKB
                if($MaxTLogAutoGrowthInKB  -eq $null) {
                    Set-TestInconclusive -Message "No config value found"
                }
                (Test-TLogGrowthSize -ServerInstance $serverInstance -MaxTLogAutoGrowthInKB $MaxTLogAutoGrowthInKB).Count | Should Be 0
            }
            
            It "$serverInstance has all the required DDL triggers" {
                $MustHaveDDLTrigger = $config.MustHaveDDLTrigger
                if($MustHaveDDLTrigger  -eq $null) {
                    Set-TestInconclusive -Message "No config value found"
                }
                (Test-MustHaveDDLTrigger -ServerInstance $serverInstance -MustHaveDDLTrigger $MustHaveDDLTrigger).Count | Should Be 0
            }
             It "$serverInstance has no oversized indexes" {
                (Test-OversizedIndexes -ServerInstance $serverInstance).Count | Should Be 0
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