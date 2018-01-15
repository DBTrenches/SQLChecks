Function Get-DbsWithoutGoodCheckDb{
    [cmdletbinding()]Param(
         [parameter(Mandatory=$true)][int]$MaxDaysAllowedSinceLastGoodCheckDb
        ,[parameter(Mandatory=$true)][string]$CommandLogDb
        ,[parameter(Mandatory=$true)][string]$ServerInstance
    )
    $query=(gc $PSScriptRoot/../SQLScripts/dbs_missing_recent_checkdb_success.sql -Raw)
    $query=$query.Replace('= 7',"= $MaxDaysAllowedSinceLastGoodCheckDb")

    Invoke-Sqlcmd -ServerInstance $ServerInstance -Database $CommandLogDb -Query $query -ErrorAction Stop
}