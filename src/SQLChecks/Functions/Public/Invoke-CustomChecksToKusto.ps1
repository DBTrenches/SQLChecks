Function Invoke-CustomChecksToKusto {
    [cmdletbinding()]
    Param(
        [Parameter(Mandatory = $true)]
        $Config,

        [Parameter(Mandatory = $true)]
        $BatchId,

        [Parameter(Mandatory = $true)]
        $Database,

        [Parameter(Mandatory = $true)]
        $Table,

        [Parameter(Mandatory = $true)]
        $ClusterUrl,

        [Parameter(Mandatory = $true)]
        $ApplicationClientId,

        [Parameter(Mandatory = $true)]
        $ApplicationKey,

        [Parameter(Mandatory = $true)]
        $Authority,

        $Tag
    )

    $invocationStartTime = [DateTime]::UtcNow
    $results = Invoke-CustomChecks -Config $config -PassThru -Show None -Tag $Tag
    $invocationEndTime = [DateTime]::UtcNow

    if ($results.TestResult.Count -gt 0) {
        $pesterResults = @()
        foreach ($testResult in $results.TestResult) {
            $pesterResults += [PSCustomObject]@{
                TimeGenerated       = $invocationStartTime.ToString()
                BatchId             = $batchId
                InvocationId        = [System.Guid]::NewGuid()
                InvocationEndTime   = $invocationEndTime.ToString()
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
        

        Send-KustoData -Database $Database -Table $Table `
            -ClusterUrl $ClusterUrl -ApplicationClientId $ApplicationClientId -ApplicationKey $ApplicationKey `
            -Authority $Authority -Json $resultJson | Out-Null

    }
    else {
        Write-Verbose "No test results for $($config.ServerInstance)"
    }
}