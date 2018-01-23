function Get-DbsWithoutAutogrow {
    [cmdletbinding()]Param(
         [parameter(Mandatory=$true)][string]$ServerInstance
        ,$excludeDbs # optional array or comma-delim string
    )

    $excludeDb=@()
    if($excludeDbs -ne $null){$excludeDb+=$excludeDbs.Split(",")}

    $query=(gc $PSScriptRoot/../SQLScripts/auto-growth-zero.sql -Raw)

    (Invoke-Sqlcmd -ServerInstance $ServerInstance -Database master -Query $query) | where {
        $excludeDb -notcontains $_.dbName
    }
}

