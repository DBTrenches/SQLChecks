Function Get-DbsWithoutGoodCheckDb{
    [cmdletbinding()]Param(
         [parameter(Mandatory=$true)][int]$MaxDaysAllowedSinceLastGoodCheckDb
        ,[parameter(Mandatory=$true)][string]$ServerInstance
        ,$excludeDbs # optional array or comma-delim string
    )
    
    $excludeDb=@()
    $excludeDb+="tempdb" # always exclude
    if($excludeDbs -ne $null){$excludeDb+=$excludeDbs.Split(",")}

    (Get-DbaLastGoodCheckDb -SqlServer $ServerInstance -ExcludeDatabase $excludeDb)| Where-Object {
        ($_.DaysSinceLastGoodCheckDb -gt $MaxDaysAllowedSinceLastGoodCheckDb) `
        -or ($_.LastGoodCheckDb -eq $null)
    } | Select Database,LastGoodCheckDb,DaysSinceLastGoodCheckDb
}