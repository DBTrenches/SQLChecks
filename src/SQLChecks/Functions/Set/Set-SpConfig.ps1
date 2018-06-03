Function Set-SpConfig {
    [cmdletbinding()]
    Param(
        [Parameter(Mandatory=$true)]
        $Config
    )
    $serverInstance = $Config.ServerInstance

    $total = 0
    $changed = 0
    foreach($configProperty in $Config.SpConfig.PSObject.Properties) {
        $total++
        $configName = $configProperty.Name
        $expectedValue = $configProperty.Value
        $configValue = (Get-DbaSpConfigure -Server $serverInstance -ConfigName $configName).ConfiguredValue
        
        if($expectedValue -ne $configValue) {
            $changed++
            Write-Verbose "Updating $configName on $serverInstance from $configValue to $expectedValue"
            Set-DbaSpConfigure -Server $serverInstance -ConfigName $configName -Value $expectedValue | Out-Null
        }
    }

    Write-Verbose "Completed updates for $serverInstance. $changed/$total settings updated"
}