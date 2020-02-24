Function Get-TempDBConfiguration {
    [cmdletbinding()]
    Param(
        [Parameter(ParameterSetName = "Config", ValueFromPipeline = $true, Position = 0)]
        $Config

        , [Parameter(ParameterSetName = "Values")]
        $ServerInstance
   
    )

    if ($PSCmdlet.ParameterSetName -eq "Config") {
        $ServerInstance = $Config.ServerInstance
    }

    $query = @"
    select  count(*) NumberOfFiles
            ,sum(size / 128) [TotalSizeMB]
    from    tempdb.sys.database_files
    where   [type] = 0;
"@

    Invoke-Sqlcmd -ServerInstance $serverInstance -query $query -Database tempdb | ForEach-Object {
        [pscustomobject]@{
            NumberOfFiles = $_.NumberOfFiles
            TotalSizeMB   = $_.TotalSizeMB
        }
    }
}