Function Test-InstanceSpConfigValue {
    [cmdletbinding()]
    Param(
        [int] $ExpectedValue
        ,[string] $ConfigName
        ,[string] $ServerInstance
    )

    $runningValue = (Get-DbaSpConfigure -Server $ServerInstance | Where-Object { $_.ConfigName -eq $ConfigName }).RunningValue
    if($runningValue -ne $ExpectedValue) {
        Write-Output "[Test-InstanceSpConfigValue][$ConfigName] Expected $ExpectedValue Found $runningValue"
    }
}