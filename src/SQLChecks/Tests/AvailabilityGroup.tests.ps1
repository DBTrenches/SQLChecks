Param(
    $Config
)

$serverInstance = $config.ServerInstance
$availabilityGroup = $config.AvailabilityGroup

Describe "AG Instance connectivity" -Tag AGInstanceConnectivity {
    It "Can connect to $serverInstance" {
        {
            Invoke-SQLCMD -TrustServerCertificate -ServerInstance $serverInstance -Query "select @@servername" -Database master
        } | Should -Not -Throw
    }
}

Describe "All primaries are healthy" -Tag AGPrimaryHealthStatus {
    $dbSummary = Get-AGDatabaseSummary $config

    foreach ($db in $dbSummary) {
        It "$($db.DatabaseName) is healthy on the primary for $availabilityGroup on $serverInstance" {
            $db.PrimarySynchronizationState | Should -Be "SYNCHRONIZED"
        }
    }
}

Describe "All synchronous commit secondaries are healthy" -Tag AGSyncCommitHealthStatus {
    $dbSummary = Get-AGDatabaseSummary $config

    $replicaCount = $config.AGSyncCommitHealthStatus.NumberOfReplicas

    foreach ($db in $dbSummary) {
        It "$($db.DatabaseName) has $replicaCount healthy sync commit secondaries for $availabilityGroup on $serverInstance" {
            $db.SynchronizedReplicas | Should -Be $replicaCount
        }
    }
}

Describe "AG is located on preferred node" -Tag AGPreferredNode {
    
    $preferredNode = $config.AGPreferredNode
    
    It "$serverInstance is primary on preferred node - $preferredNode" {
        $SQLResult = Invoke-SQLCMD -TrustServerCertificate -ServerInstance $serverInstance -Query "select @@servername as ServerName" -Database master 
        $SQLResult.ServerName | Should -Be $preferredNode
    }
    
}