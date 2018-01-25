Function Get-AutoGrowthRisks {
    [cmdletbinding()]Param(
         [parameter(Mandatory=$true)][string]$ServerInstance
        ,$WhitelistFilegroups # optional array or comma-delim string
    )

    $WLFGNames=@()
    if($WhitelistFilegroups -ne $null){$WLFGNames+=$WhitelistFilegroups.Split(",")}

    $query=(Get-Content $PSScriptRoot/../SQLScripts/auto-growth-will-fail-for-max_size.sql -Raw)
    
    (Invoke-Sqlcmd -ServerInstance $ServerInstance -Database master -Query $query) | Where-Object {
        $WLFGNames -notcontains $_.fName
    } | ForEach-Object {
        [pscustomobject]@{
            Server = $_.srvr
            Database = $_.db_name
            FileName = $_.FileName
            Growth = $_.growth
            CurrentSizeMB = $_.cur_size_mb
            MaxSizeMB = $_.max_size_mb
            NextGrowthSizeMB = $_.next_growth_size_mb
            GrowFileCommand = $_.grow_file_cmd
        }
    }
}