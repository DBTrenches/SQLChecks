Function Get-CompleteDBBackupHistory {
    [cmdletbinding()]
    Param(
        [Parameter(ParameterSetName = "Config", ValueFromPipeline = $true, Position = 0)]
        $Config

        , [Parameter(ParameterSetName = "Values")]
        [string]
        $ServerInstance

        , [parameter(Mandatory = $true)]
        [string]
        $DatabaseName

        , [parameter(Mandatory = $true)]
        [Int]
        $MaxHours

    )

    if ($PSCmdlet.ParameterSetName -eq "Config") {
        $ServerInstance = $Config.ServerInstance
    }



    $DBSettings = Get-DBSettings -ServerInstance $ServerInstance -DatabaseName $DatabaseName

    if ($DBSettings.IsAvailabilityGroupDatabase -eq 1){
        $BackupHistory = Get-AGDBBackupHistory -ServerInstance $ServerInstance -AvailabilityGroup $DBSettings.AvailabilityGroup -DatabaseName $DatabaseName -HistoryHours $maxHours
    }

    else { 
        $BackupHistory = Get-DBBackupHistory -ServerInstance $ServerInstance -DatabaseName $DatabaseName -HistoryHours $maxHours
    }

    return $BackupHistory

}