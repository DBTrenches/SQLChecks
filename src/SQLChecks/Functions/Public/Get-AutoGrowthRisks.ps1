Function Get-AutoGrowthRisks {
    [cmdletbinding()]
    Param(
        [Parameter(ParameterSetName = "Config", ValueFromPipeline = $true, Position = 0)]
        $Config

        , [Parameter(ParameterSetName = "Values")]
        $ServerInstance

        , [parameter(Mandatory = $true)]
        [string]
        $Database

        , [parameter(ParameterSetName = "Values")]
        [string[]]
        $WhitelistFiles
    )

    if ($PSCmdlet.ParameterSetName -eq "Config") {
        $ServerInstance = $Config.ServerInstance
        $WhitelistFiles = $Config.ShouldCheckForAutoGrowthRisks.WhitelistFiles
    }

    $query = @"
    ;with fileGrowth as (
        select mf.database_id
              ,mf.[file_id]
              ,mf.[type]
              ,mf.[type_desc]
              ,mf.[state]
              ,mf.state_desc
              ,mf.growth
              ,mf.is_percent_growth
              ,growth_mb=
                   case mf.is_percent_growth
                       when 1 then (mf.growth/100.)*(try_cast(size as bigint)*8192.)/power(1024,2)
                       else (try_cast(mf.growth as bigint)*8192.)/power(1024,2)
                   end
              ,size_mb=(try_cast(mf.size as bigint)*8192.)/power(1024,2)
              ,max_size_mb=(try_cast(nullif(mf.max_size,-1) as bigint)*8192.)/power(1024,2)
              ,d.name as db_name
              ,f_name=mf.[name]
              ,f_path=mf.physical_name
        from sys.master_files mf
        join sys.databases as d
        on  d.database_id = mf.database_id
        where max_size <> -1
        and d.name = '$Database'
    )
    select @@servername as srvr
          ,[db_name]
          ,f_name
          ,growth_mb=try_convert(float,growth_mb)
          ,is_percent_growth
          ,cur_size_mb=try_convert(float,size_mb)
          ,max_size_mb=try_convert(float,max_size_mb)
          ,next_growth_size_mb=try_convert(float,size_mb+growth_mb)
          ,grow_file_cmd='alter database ['+[db_name]+'] modify file (name=N'''+f_name+''',maxsize='+try_cast(ceiling(size_mb+growth_mb+1) as varchar)+'mb);'
          ,f_path
          ,database_id
          ,[file_id]
          ,[type]
          ,[type_desc]
          ,[state]
          ,state_desc
    from fileGrowth fg
    where (size_mb+growth_mb)>max_size_mb;
"@

    (Invoke-Sqlcmd -ServerInstance $ServerInstance -Database master -Query $query) | Where-Object {
        $WhitelistFiles -notcontains $_.fName
    } | ForEach-Object {
        [pscustomobject]@{
            Server           = $_.srvr
            Database         = $_.db_name
            FileName         = $_.FileName
            Growth           = $_.growth
            CurrentSizeMB    = $_.cur_size_mb
            MaxSizeMB        = $_.max_size_mb
            NextGrowthSizeMB = $_.next_growth_size_mb
            GrowFileCommand  = $_.grow_file_cmd
        }
    }
}