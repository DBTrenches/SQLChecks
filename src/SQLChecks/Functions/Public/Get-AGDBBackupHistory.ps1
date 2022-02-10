Function Get-AGDBBackupHistory {
    [cmdletbinding()]
    Param(
        
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $ServerInstance,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $DatabaseName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $AvailabilityGroup,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [Int]
        $HistoryHours

    )

    $ConsolidatedBackupHistory = @()

    $BackupHistory = @(Get-DBBackupHistory -ServerInstance $ServerInstance -DatabaseName $DatabaseName -HistoryHours $HistoryHours)
    $ConsolidatedBackupHistory += $BackupHistory

    $ReplicaServers = @(Get-AGNodes -ServerInstance $ServerInstance -AvailabilityGroup $AvailabilityGroup)

    foreach ($server in $ReplicaServers.ReplicaServer) {
        $BackupHistory = @(Get-DBBackupHistory -ServerInstance $server -DatabaseName $DatabaseName -HistoryHours $HistoryHours)
        $ConsolidatedBackupHistory += $BackupHistory
    }

    return $ConsolidatedBackupHistory    

}