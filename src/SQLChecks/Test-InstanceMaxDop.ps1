Function Test-InstanceMaxDop {
    [cmdletbinding()]
    Param(
        [int] $ExpectedValue
        ,[string] $ServerInstance
    )

    $maxdop = (Get-DbaSpConfigure -Server $ServerInstance | Where-Object { $_.ConfigName -eq "MaxDegreeOfParallelism" }).RunningValue
    if($maxdop -ne $ExpectedValue) {
        Write-Output "Expected $ExpectedValue Found $maxdop"
    }
}