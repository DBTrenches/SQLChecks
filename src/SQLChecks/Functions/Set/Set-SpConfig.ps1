Function Set-SpConfig {
    [cmdletbinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [string]
        $Config
    )
    $serverInstance = $Config.ServerInstance

    $total = 0
    $changed = 0
    foreach($configProperty in $spconfig.PSObject.Properties) {
        $total++
        $configName = $configProperty.Name
        $expectedValue = $configProperty.Value
        $configValue = (Get-DbaSpConfigure -Server $serverInstance -ConfigName $configName).ConfiguredValue
        
        if($expectedValue -ne $configValue) {
            $changed++
            Write-Verbose "Updating $configName on $serverInstance from $configValue to $expectedValue"
            Set-DbaSpConfigure -Server $serverInstance -Name $configName -Value $expectedValue
        }
    }

    Write-Verbose "sp_configure update on $serverInstance complete - $changed/$total values updated"
}