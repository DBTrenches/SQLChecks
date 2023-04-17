Function Test-Sysadmins {
    [cmdletbinding()]
    Param(
        [Parameter(ParameterSetName = "Config", ValueFromPipeline = $true, Position = 0)]
        $Config

        , [Parameter(ParameterSetName = "Values")]
        $ServerInstance

        , [Parameter(ParameterSetName = "Values")]
        $Sysadmins
    )

    if ($PSCmdlet.ParameterSetName -eq "Config") {
        $ServerInstance = $Config.ServerInstance
        $Sysadmins = $Config.Sysadmins
    }

    $serverSysadmins = @(Get-Sysadmins -ServerInstance $serverInstance)

    Compare-SqlChecks -ReferenceObject $Sysadmins -DifferenceObject $serverSysadmins
}