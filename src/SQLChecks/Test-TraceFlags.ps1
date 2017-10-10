Function Test-TraceFlags {
    [cmdletbinding()]
    Param(
        [int[]] $ExpectedFlags
        ,[string] $ServerInstance
    )

    $dbFlags = Get-DbaTraceFlag -SqlInstance $serverInstance
    $flags = @()

    foreach($flag in $dbFlags)
    {
        $flags += $flag.TraceFlag
    }

    $comparison = @(Compare-Object -ReferenceObject $expectedFlags -DifferenceObject $flags)

    Write-Verbose $comparison

    return $comparison.Count
}