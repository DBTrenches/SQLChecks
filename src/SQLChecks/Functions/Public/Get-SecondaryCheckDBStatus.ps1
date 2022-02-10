Function Get-SecondaryCheckDBStatus {
    [cmdletbinding()]
    Param(
        [Parameter(ParameterSetName = "Config", ValueFromPipeline = $true, Position = 0)]
        $Config

        , [Parameter(ParameterSetName = "Values")]
        [string]
        $ServerInstance

        , [Parameter(ParameterSetName = "Values")]
        [Int[]]
        $maxDays

		, [Parameter(ParameterSetName = "Values")]
        [string[]]
        $ExcludedDatabases

    )

    if ($PSCmdlet.ParameterSetName -eq "Config") {
        $ServerInstance = $Config.ServerInstance
        $maxDays = $Config.CustomCheck_LastGoodSecondaryReplicaCheckDb.MaxDaysSinceLastGoodCheckDB
		$ExcludedDatabases = $Config.CustomCheck_LastGoodSecondaryReplicaCheckDb.ExcludedDatabases
    }

    $query = @"
exec Utility.GetReplicaDatabasesWithoutGoodCheckdb @days = '${maxDays}'
"@


    Invoke-Sqlcmd -ServerInstance $ServerInstance -Database "DBAdmin" -QueryTimeout 0 -Query $query | Where-Object {
        $ExcludedDatabases -notcontains $_.DatabaseName } | ForEach-Object {
            [pscustomobject]@{
                Database                 = $_.DatabaseName
                LastGoodCheckDb          = $_.LastGoodCheckDbDate
                DaysSinceLastGoodCheckDB = $_.DaysSinceLastGoodCheckDb
            }
        }

}