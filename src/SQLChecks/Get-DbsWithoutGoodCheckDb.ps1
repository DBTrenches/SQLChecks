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