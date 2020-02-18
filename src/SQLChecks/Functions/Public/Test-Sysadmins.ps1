Function Test-Sysadmins {
    [cmdletbinding()]
    Param(
        [Parameter(ParameterSetName = "Config", ValueFromPipeline = $true, Position = 0)]
        $Config

        ,[Parameter(ParameterSetName = "Values")]
        $ServerInstance

        , [Parameter(ParameterSetName = "Values")]
        $Sysadmins
    )

    if ($PSCmdlet.ParameterSetName -eq "Config") {
        $ServerInstance = $Config.ServerInstance
        $Sysadmins = $Config.Sysadmins
    }

    $serverSysadmins = @(Get-Sysadmins -ServerInstance $serverInstance)

    $comparison = @(Compare-Object -ReferenceObject $Sysadmins -DifferenceObject $serverSysadmins)

    foreach ($delta in $comparison) {
        [pscustomobject]@{
            Sysadmin = $delta.InputObject
            Issue     = if ($delta.SideIndicator -eq "<=") { "Missing from target" } else { "Extra on target" }
        }
    }
}