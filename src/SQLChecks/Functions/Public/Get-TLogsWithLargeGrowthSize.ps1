Function Get-TLogsWithLargeGrowthSize {
    [cmdletbinding()]
    Param(
        [Parameter(ParameterSetName = "Config", ValueFromPipeline = $true, Position = 0)]
        $Config

        , [Parameter(ParameterSetName = "Values")]
        $ServerInstance

        , [Parameter(ParameterSetName = "Values")]
        [int]
        $MaxTLogAutoGrowthInKB

        , [string]
        $Database
    )

    if ($PSCmdlet.ParameterSetName -eq "Config") {
        $ServerInstance = $Config.ServerInstance
        $MaxTLogAutoGrowthInKB = $Config.MaxTLogAutoGrowthInKB
    }

    $query = @"
    select  d.name as DatabaseName
    ,s.name as FileName
    ,s.growth * 8 as GrowthKB
from    sys.master_files s
join    sys.databases as d
on      s.database_id = d.database_id
where   s.type = 1
and (( s.growth * 8 ) > $MaxTLogAutoGrowthInKB and s.is_percent_growth = 0)
and s.database_id = db_id();
"@

    Invoke-Sqlcmd -ServerInstance $serverInstance -Database $Database -query $query |ForEach-Object {
        [pscustomobject]@{
            Database = $_.DatabaseName
            FileName = $_.FileName
            GrowthKB = $_.GrowthKB
        }
    }
}



