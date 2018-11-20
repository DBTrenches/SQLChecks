# Adapted from https://docs.microsoft.com/en-us/azure/log-analytics/log-analytics-data-collector-api
# Create the function to create and post the request
Function Export-LogAnalytics {
    [cmdletbinding()]
    Param(
        [Parameter(Mandatory=$true)]
        $CustomerId,

        [Parameter(Mandatory=$true)]
        $SharedKey,

        [Parameter(Mandatory=$true)]
        $Object,

        [Parameter(Mandatory=$true)]
        $LogType,

        [Parameter(Mandatory=$true)]
        $TimeStampField
    )
    $bodyAsJson = ConvertTo-Json $object
    $body = [System.Text.Encoding]::UTF8.GetBytes($bodyAsJson)

    $method = "POST"
    $contentType = "application/json"
    $resource = "/api/logs"
    $rfc1123date = [DateTime]::UtcNow.ToString("r")
    $contentLength = $body.Length

    $signatureArguments = @{
        CustomerId = $customerId
        SharedKey = $sharedKey
        Date = $rfc1123date
        ContentLength = $contentLength
        Method = $method
        ContentType = $contentType
        Resource = $resource
    }

    $signature = Get-LogAnalyticsSignature @signatureArguments
    
    $uri = "https://" + $customerId + ".ods.opinsights.azure.com" + $resource + "?api-version=2016-04-01"

    $headers = @{
        "Authorization" = $signature;
        "Log-Type" = $logType;
        "x-ms-date" = $rfc1123date;
        "time-generated-field" = $TimeStampField;
    }

    Invoke-WebRequest -Uri $uri -Method $method -ContentType $contentType -Headers $headers -Body $body -UseBasicParsing | Out-Null
}