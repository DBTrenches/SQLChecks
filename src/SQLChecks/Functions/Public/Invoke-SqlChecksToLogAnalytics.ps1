Function Invoke-SqlChecksToLogAnalytics {
    [cmdletbinding()]
    Param(
        [Parameter(Mandatory=$true)]
        $Config,

        [Parameter(Mandatory=$true)]
        $BatchId,

        [Parameter(Mandatory=$true)]
        $CustomerId,

        [Parameter(Mandatory=$true)]
        $SharedKey,

        $Tag
    )

    $invocationStartTime = [DateTime]::UtcNow
    $results = Invoke-SqlChecks -Config $config -PassThru -Show None -Tag $Tag
    $invocationEndTime = [DateTime]::UtcNow

    if($Results.Count -gt 0) {
        $pesterResults = @()
        foreach($testResult in $results.TestResult) {
            $pesterResults += [PSCustomObject]@{
                BatchId = $BatchId
                InvocationId = [System.Guid]::NewGuid()
                InvocationStartTime = $InvocationStartTime
                InvocationEndTime = $InvocationEndTime
                HostComputer = $env:computername
                TargetComputer = $config.ServerInstance
                TimeTaken = $testResult.Time.TotalMilliseconds
                Passed = $testResult.Passed
                Describe = $testResult.Describe
                Context = $testResult.Context
                Name = $testResult.Name
                FailureMessage = $testResult.FailureMessage
                Result = $testResult.Result
                Identifier = "SQLChecks"
            }
        }

        $exportArguments = @{
            CustomerId = $CustomerId
            SharedKey = $SharedKey
            LogType = "PesterResult"
            TimeStampField = "InvocationStartTime"
        }

        Write-Verbose "Exporting $($pesterResults.Count) results"
        Export-LogAnalytics @exportArguments $pesterResults
    } else {
        Write-Verbose "No test results for $($config.ServerInstance)"
    }
}