Function Get-TLogWithPercentageGrowth {
    [cmdletbinding()]
    Param(
        [Parameter(ParameterSetName = "Config", ValueFromPipeline = $true, Position = 0)]
        $Config

        , [Parameter(ParameterSetName = "Values")]
        [string]
        $ServerInstance

        , [string]
        $Database
    )

    if ($PSCmdlet.ParameterSetName -eq "Config") {
        $ServerInstance = $Config.ServerInstance
    }

    $query = @"
select  d.name as DatabaseName
    ,s.name as FileName
    ,s.growth as GrowthPercentage
from    sys.master_files s
join    sys.databases as d
on      s.database_id = d.database_id
where  s.type = 1
and s.is_percent_growth =1
and s.database_id = db_id();
"@

    Invoke-Sqlcmd -ServerInstance $serverInstance -query $query -Database $Database | ForEach-Object {
        [pscustomobject]@{
            Database         = $_.DatabaseName
            FileName         = $_.FileName
            GrowthPercentage = $_.GrowthPercentage
        }
    }
}



