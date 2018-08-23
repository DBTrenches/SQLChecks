Function Export-SqlChecksResultsToLogAnalytics {
    [cmdletbinding()]
    Param(
        [Parameter(Mandatory=$true)]
        $BatchId,

        [Parameter(Mandatory=$true)]
        $InvocationId,

        [Parameter(Mandatory=$true)]
        $InvocationStartTime,

        [Parameter(Mandatory=$true)]
        $InvocationEndTime,

        [Parameter(Mandatory=$true)]
        $HostComputer,

        [Parameter(Mandatory=$true)]
        $TargetComputer,

        [Parameter(Mandatory=$true)]
        $TestResults
    )
    
    $results = @()

    foreach($testResult in $TestResults.TestResult) {
        $results += [PSCustomObject]@{
            BatchId = $BatchId
            InvocationId = $InvocationId
            InvocationStartTime = $InvocationStartTime
            InvocationEndTime = $InvocationEndTime
            HostComputer = $HostComputer
            TargetComputer = $TargetComputer
            TimeTaken = $testResult.Time.TotalMilliseconds
            Passed = $testResult.Passed
            Describe = $testResult.Describe
            Context = $testResult.Context
            Name = $testResult.Name
            FailureMessage = $testResult.FailureMessage
            Result = $testResult.Result
        }
    }

    # TODO: Upload it not echo it
    Write-Output $results | Out-GridView
}