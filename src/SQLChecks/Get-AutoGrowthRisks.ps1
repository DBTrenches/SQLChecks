Function Get-AutoGrowthRisks {
    [cmdletbinding()]Param(
         [parameter(Mandatory=$true)][string]$ServerInstance
        ,$WhitelistFilegroups # optional array or comma-delim string
    )

    $WLFGNames=@()
    if($WhitelistFilegroups -ne $null){$WLFGNames+=$WhitelistFilegroups.Split(",")}

    $query=(gc $PSScriptRoot/../SQLScripts/auto-growth-will-fail-for-max_size.sql -Raw)
    
    (Invoke-Sqlcmd -ServerInstance $ServerInstance -Database master -Query $query) | where {
        $WLFGNames -notcontains $_.fName
    } | Select srvr,dbName,fName,growthMb,curSizeMb,maxSizeMb,nextGrowthSizeMb,cmd | ft
}