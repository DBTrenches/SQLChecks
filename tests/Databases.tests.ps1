Param(
    $configs
)

Describe "SQL Server Databases" {
    Context "Per-Database settings" {
        foreach($config in $configs) {
            $serverInstance = $config.ServerInstance
            
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
                (Get-DatabasesWithoutDDLTrigger -ServerInstance $serverInstance -TriggerName $MustHaveDDLTrigger).Count | Should Be 0
            }

            It "$serverInstance has no oversized indexes" {

                (Get-OversizedIndexes -ServerInstance $serverInstance).Count | Should Be 0
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