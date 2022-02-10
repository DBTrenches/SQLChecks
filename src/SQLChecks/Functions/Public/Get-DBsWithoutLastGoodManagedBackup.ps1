Function Get-DBsWithoutLastGoodManagedBackup {
    [cmdletbinding()]
    Param(
        [Parameter(ParameterSetName = "Config", ValueFromPipeline = $true, Position = 0)]
        $Config

        , [Parameter(ParameterSetName = "Values")]
        [string]
        $ServerInstance

        , [Parameter(ParameterSetName = "Values")]
        [Int[]]
        $maxHours

		, [Parameter(ParameterSetName = "Values")]
        [string[]]
        $ExcludedDatabases

    )

    if ($PSCmdlet.ParameterSetName -eq "Config") {
        $ServerInstance = $Config.ServerInstance
        $maxHours = $Config.CustomCheck_LastGoodManagedBackup.MaxHoursSinceLastGoodBackup
		$ExcludedDatabases = $Config.CustomCheck_LastGoodManagedBackup.ExcludedDatabases
    }

    $query = @"
exec Utility.GetDbsWithoutLastGoodManagedBackup @HoursSinceLastGoodBackup = '${maxHours}'
"@


    Invoke-Sqlcmd -ServerInstance $ServerInstance -Database "DBAdmin" -QueryTimeout 0 -Query $query | Where-Object {
        $ExcludedDatabases -notcontains $_.DBName } | ForEach-Object {
            [pscustomobject]@{
                Database                 = $_.DBName
                LastBackupFinishDate          = $_.LastBackupFinishDate
            }
        }

}