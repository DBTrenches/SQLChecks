Function Get-DbsWithoutGoodCheckDb{
    [cmdletbinding()]Param(
         [parameter(Mandatory=$true)][int]$MaxDaysAllowedSinceLastGoodCheckDb
        ,[parameter(Mandatory=$true)][string]$ServerInstance
    )
    
    (Get-DbaLastGoodCheckDb -SqlServer $ServerInstance)| Where-Object {
        ($_.DaysSinceLastGoodCheckDb -gt $MaxDaysAllowedSinceLastGoodCheckDb) `
        -or ($_.LastGoodCheckDb -eq $null)
    } | Select Database,LastGoodCheckDb,DaysSinceLastGoodCheckDb
}