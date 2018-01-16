Function Get-DbsWithoutGoodCheckDb{
    [cmdletbinding()]Param(
         [parameter(Mandatory=$true)][int]$MaxDaysAllowedSinceLastGoodCheckDb
        ,[parameter(Mandatory=$true)][string]$ServerInstance
    )
# ripped shamelessly from https://www.mssqltips.com/sqlservertip/2948/check-dbcc-checkdb-last-execution-using-powershell/
    
    $lastKnownGood=@()

    $dbs=Get-SqlDatabase -ServerInstance $ServerInstance
    foreach($db in $dbs){
        $dbName=$db.Name
        $dbInfo=(Invoke-Sqlcmd -ServerInstance $ServerInstance -Database $dbName -Query "dbcc dbinfo() with tableresults;")
        $dbInfo | Add-Member -Type NoteProperty -Name dbName -Value $dbName
        $lastKnownGood+=($dbInfo | Where-Object {$_.Field -eq "dbi_dbccLastKnownGood"} | Select-Object dbName, Field, Value)
    }

    $lastKnownGood | Add-Member -Type NoteProperty -Name DaysSinceLastGoodCheckDb -Value $null

    foreach($db in $lastKnownGood){
        [datetime]$dt=$db.VALUE
        $daysSince=((Get-Date)-$dt)
        $db.DaysSinceLastGoodCheckDb=$daysSince.Days
    }

    $lastKnownGood | Where-Object {$_.DaysSinceLastGoodCheckDb -gt $MaxDaysAllowedSinceLastGoodCheckDb} | Select dbName,DaysSinceLastGoodCheckDb
}