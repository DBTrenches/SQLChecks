Function Set-SpConfig {
    [cmdletbinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [string]
        $Config
    )
    $serverInstance = $Config.ServerInstance

    foreach($configProperty in $spconfig.PSObject.Properties) {
        $configName = $configProperty.Name
        $expectedValue = $configProperty.Value
        $configValue = (Get-DbaSpConfigure -Server $serverInstance -ConfigName $configName).ConfiguredValue
        
        if($expectedValue -ne $configValue) {
            Write-Verbose "Updating $configName on $serverInstance from $configValue to $expectedValue"
            Set-DbaSpConfigure -Server $serverInstance -Name $configName -Value $expectedValue
        }
    }
}