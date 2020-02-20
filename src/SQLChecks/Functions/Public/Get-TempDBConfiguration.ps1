Function Get-TempDBConfiguration {
    [cmdletbinding()]
    Param(
        [Parameter(ParameterSetName = "Config", ValueFromPipeline = $true, Position = 0)]
        $Config

        , [Parameter(ParameterSetName = "Values")]
        $ServerInstance

        , [Parameter(ParameterSetName = "Values")]
        [int]
        $NumberOfFiles

        , [Parameter(ParameterSetName = "Values")]
        [int]
        $TotalSizeMB

   
    )

    if ($PSCmdlet.ParameterSetName -eq "Config") {
        $ServerInstance = $Config.ServerInstance
        $NumberOfFiles = $Config.TempDBConfiguration.NumberOfFiles
        $TotalSizeMB = $Config.TempDBConfiguration.$TotalSizeMB
    }

    $query = @"
    select  count(*) NumberOfFiles
       ,sum(size / 128) [TotalSizeMB]
    from    tempdb.dbo.sysfiles
    where   groupid = 1;
"@

    Invoke-Sqlcmd -ServerInstance $serverInstance -query $query -Database tempdb | ForEach-Object {
        [pscustomobject]@{
            NumberOfFiles = $_.NumberOfFiles
            TotalSizeMB   = $_.TotalSizeMB
        }
    }
}