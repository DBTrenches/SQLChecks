Function Test-TraceFlags {
    [cmdletbinding()]
    Param(
        [int[]]
        $ExpectedFlags,
        
        [string]
        $ServerInstance
    )

    $dbFlags = Get-DbaTraceFlag -SqlInstance $serverInstance
    $flags = @()

    foreach($flag in $dbFlags)
    {
        $flags += $flag.TraceFlag
    }

    $comparison = @(Compare-Object -ReferenceObject $expectedFlags -DifferenceObject $flags)

    foreach($delta in $comparison)     
    {
        [pscustomobject]@{
            TraceFlag = $delta.InputObject
            Issue = if($delta.SideIndicator -eq "<=") { "Missing from target" } else { "Extra on target" }
        }
    }
}