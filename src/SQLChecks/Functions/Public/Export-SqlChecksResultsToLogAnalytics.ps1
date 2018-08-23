Function Export-SqlChecksResultsToLogAnalytics {
    [cmdletbinding()]
    Param(
        [Parameter(Mandatory=$true)]
        $CustomerId,

        [Parameter(Mandatory=$true)]
        $SharedKey,

        [Parameter(Mandatory=$true)]
        $LogType,

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
    $payload = ConvertTo-Json $results
    $encodedPayload = [System.Text.Encoding]::UTF8.GetBytes($payload)

    $logAnalyticsArguments = @{
        CustomerId = $CustomerId
        SharedKey = $SharedKey
        LogType = $LogType
        TimeStampField = "InvocationStartTime"
        Body = $encodedPayload
    }

    Post-LogAnalyticsData @logAnalyticsArguments
}