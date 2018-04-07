Function Get-DbsWithoutGoodCheckDb{
    [cmdletbinding()]Param(
         [parameter(Mandatory=$true)][int]$MaxDaysAllowedSinceLastGoodCheckDb
        ,[parameter(Mandatory=$true)][string]$ServerInstance
        ,[string[]]$ExcludedDatabases
    )
    
    if($ExcludedDatabases -eq $null)
    {
        $ExcludedDatabases = @("tempdb")
    } else {
        $ExcludedDatabases+="tempdb" # always exclude
    }

    (Get-DbaLastGoodCheckDb -SqlServer $ServerInstance -ExcludeDatabase $ExcludedDatabases)| Where-Object {
        ($_.DaysSinceLastGoodCheckDb -ge $MaxDaysAllowedSinceLastGoodCheckDb) `
        -or ($_.LastGoodCheckDb -eq $null)
    } | ForEach-Object {
        [pscustomobject]@{
            Database = $_.Database
            LastGoodCheckDB = $_.LastGoodCheckDb
            DaysSinceLastGoodCheckDB = $_.DaysSinceLastGoodCheckDb
        }
    }
}