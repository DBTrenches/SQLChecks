Function Test-StartupXEvents {
    [cmdletbinding()]
    Param(
        [string]
        $ServerInstance,
        
        [string[]]
        $ExpectedSessions
    )

    $query = @"
select  s.name
from    sys.server_event_sessions as s
where   s.startup_state = 1; 
"@  

    $sessions = @(Invoke-Sqlcmd -ServerInstance $ServerInstance -Query $query | Select-Object -ExpandProperty name)

    $comparison = @(Compare-Object -ReferenceObject $ExpectedSessions -DifferenceObject $Sessions)

    foreach($delta in $comparison)     
    {
        [pscustomobject]@{
            EventSession = $delta.InputObject
            Issue = if($delta.SideIndicator -eq "<=") { "Missing from target" } else { "Extra on target" }
        }
    }
}