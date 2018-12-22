Function Test-TraceFlags {
    [cmdletbinding()]
    Param(
        [Parameter(ParameterSetName = "Config", ValueFromPipeline = $true, Position = 0)]
        $Config

        , [Parameter(ParameterSetName = "Values")]
        $ServerInstance

        , [Parameter(ParameterSetName = "Values")]
        $TraceFlags
    )

    if ($PSCmdlet.ParameterSetName -eq "Config") {
        $ServerInstance = $Config.ServerInstance
        $TraceFlags = $Config.TraceFlags
    }

    $flags = @(Get-TraceFlags -ServerInstance $serverInstance)

    $comparison = @(Compare-Object -ReferenceObject $TraceFlags -DifferenceObject $flags)

    foreach ($delta in $comparison) {
        [pscustomobject]@{
            TraceFlag = $delta.InputObject
            Issue     = if ($delta.SideIndicator -eq "<=") { "Missing from target" } else { "Extra on target" }
        }
    }
}