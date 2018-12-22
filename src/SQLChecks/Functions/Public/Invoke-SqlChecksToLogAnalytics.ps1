Function Invoke-SqlChecksToLogAnalytics {
    [cmdletbinding()]
    Param(
        [Parameter(Mandatory = $true)]
        $Config,

        [Parameter(Mandatory = $true)]
        $BatchId,

        [Parameter(Mandatory = $true)]
        $CustomerId,

        [Parameter(Mandatory = $true)]
        $SharedKey,

        $Tag
    )

    $invocationStartTime = [DateTime]::UtcNow
    $results = Invoke-SqlChecks -Config $config -PassThru -Show None -Tag $Tag
    $invocationEndTime = [DateTime]::UtcNow

    if ($results.TestResult.Count -gt 0) {
        $pesterResults = @()
        foreach ($testResult in $results.TestResult) {
            $pesterResults += [PSCustomObject]@{
                BatchId             = $batchId
                InvocationId        = [System.Guid]::NewGuid()
                InvocationStartTime = $invocationStartTime
                InvocationEndTime   = $invocationEndTime
                HostComputer        = $env:computername
                Target              = $config.ServerInstance
                TimeTaken           = $testResult.Time.TotalMilliseconds
                Passed              = $testResult.Passed
                Describe            = $testResult.Describe
                Context             = $testResult.Context
                Name                = $testResult.Name
                FailureMessage      = $testResult.FailureMessage
                Result              = $testResult.Result
                Identifier          = "SQLChecks"
            }
        }

        Write-Verbose "Exporting $($pesterResults.Count) results"

        $resultJson = ConvertTo-Json $pesterResults
        $sendArguments = @{
            CustomerId     = $CustomerId
            SharedKey      = $SharedKey
            LogType        = "PesterResult"
            TimeStampField = "InvocationStartTime"
            Body           = $resultJson
        }

        Send-OMSAPIIngestionFile @sendArguments | Out-Null
    }
    else {
        Write-Verbose "No test results for $($config.ServerInstance)"
    }
}