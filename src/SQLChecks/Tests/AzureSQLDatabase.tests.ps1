Param(
    $Config
)

$serverInstance = $config.ServerInstance
$AzureDBCertificateAuth = $config.AzureDBCertificateAuth
$TargetCredential = $config.TargetCredential

$databasesToCheckParams = @{
    ServerInstance = $serverInstance
    AzureDBCertificateAuth = $AzureDBCertificateAuth
    TargetCredential = $TargetCredential
}


Describe "Data file space used" -Tag AzureDBMaxDataFileSize {
    $spaceUsedPercentLimit = $Config.AzureDBMaxDataFileSize.SpaceUsedPercent

    $databases = Get-AzureSQLDatabasesToCheck @databasesToCheckParams
    foreach ($database in $databases) {
        It "$database files are all under $spaceUsedPercentLimit% full on $serverInstance" {
            @(Get-DatabaseFilesOverMaxDataFileSpaceUsed -Config $Config -Database $database).Count | Should -Be 0
        }
    }
}

Describe "Duplicate indexes" -Tag AzureDBCheckDuplicateIndexes {
    $databasesToCheckParams.ExcludedDatabases = $Config.AzureDBCheckDuplicateIndexes.ExcludeDatabase

    $databases = Get-AzureSQLDatabasesToCheck @databasesToCheckParams

    foreach ($database in $databases) {
        It "$database has no duplicate indexes on $serverInstance" {
            @(Get-DuplicateIndexes -Config $Config -Database $database).Count | Should Be 0
        }
    }
}
