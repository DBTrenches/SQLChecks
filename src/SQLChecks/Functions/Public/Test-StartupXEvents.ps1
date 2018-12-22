Function Test-StartupXEvents {
    [cmdletbinding()]
    Param(
        [Parameter(ParameterSetName = "Config", ValueFromPipeline = $true, Position = 0)]
        $Config

        , [Parameter(ParameterSetName = "Values")]
        $ServerInstance

        , [Parameter(ParameterSetName = "Values")]
        [string[]]
        $StartupXEvents
    )

    if ($PSCmdlet.ParameterSetName -eq "Config") {
        $ServerInstance = $Config.ServerInstance
        $StartupXEvents = $Config.StartupXEvents

        if (!$StartupXEvents) {
            $StartupXEvents = @()
        }
    }

    $query = @"
select  s.name
from    sys.server_event_sessions as s
where   s.startup_state = 1;
"@

    $sessions = @(Invoke-Sqlcmd -ServerInstance $ServerInstance -Query $query | Select-Object -ExpandProperty name)

    $comparison = @(Compare-Object -ReferenceObject $StartupXEvents -DifferenceObject $Sessions)

    foreach ($delta in $comparison) {
        [pscustomobject]@{
            EventSession = $delta.InputObject
            Issue        = if ($delta.SideIndicator -eq "<=") { "Missing from target" } else { "Extra on target" }
        }
    }
}