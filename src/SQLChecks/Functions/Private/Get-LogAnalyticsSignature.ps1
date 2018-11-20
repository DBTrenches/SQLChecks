# Adapted from https://docs.microsoft.com/en-us/azure/log-analytics/log-analytics-data-collector-api
Function Get-LogAnalyticsSignature {
    [cmdletbinding()]
    Param (
        [Parameter(Mandatory=$true)]
        $CustomerId,

        [Parameter(Mandatory=$true)]
        $SharedKey,

        [Parameter(Mandatory=$true)]
        $Date,

        [Parameter(Mandatory=$true)]
        $ContentLength,

        [Parameter(Mandatory=$true)]
        $Method,

        [Parameter(Mandatory=$true)]
        $ContentType,

        [Parameter(Mandatory=$true)]
        $Resource
    )
    $xHeaders = "x-ms-date:" + $date
    $stringToHash = $method + "`n" + $contentLength + "`n" + $contentType + "`n" + $xHeaders + "`n" + $resource

    $bytesToHash = [Text.Encoding]::UTF8.GetBytes($stringToHash)
    $keyBytes = [Convert]::FromBase64String($sharedKey)

    $sha256 = New-Object System.Security.Cryptography.HMACSHA256
    $sha256.Key = $keyBytes
    $calculatedHash = $sha256.ComputeHash($bytesToHash)
    $encodedHash = [Convert]::ToBase64String($calculatedHash)
    $authorization = 'SharedKey {0}:{1}' -f $customerId,$encodedHash
    return $authorization
}