Function Get-AutoGrowthRisks {
    [cmdletbinding()]Param(
         [parameter(Mandatory=$true)][string]$ServerInstance
        ,$WhitelistFiles # optional array or comma-delim string
    )

    $whitelistedFiles=@()
    if($WhitelistFiles -ne $null){$whitelistedFiles+=$WhitelistFiles.Split(",")}

    $query=@"
    ;with fileGrowth as (
        select database_id
              ,[file_id]
              ,[type]
              ,[type_desc]
              ,[state]
              ,state_desc
              ,growth
              ,is_percent_growth
              ,growth_mb=
                   case is_percent_growth 
                       when 1 then (growth/100.)*(try_cast(size as bigint)*8192.)/power(1024,2) 
                       else (try_cast(growth as bigint)*8192.)/power(1024,2) 
                   end
              ,size_mb=(try_cast(size as bigint)*8192.)/power(1024,2) 
              ,max_size_mb=(try_cast(nullif(max_size,-1) as bigint)*8192.)/power(1024,2) 
              ,[db_name]=db_name(database_id)
              ,f_name=[name]
              ,f_path=physical_name
        from sys.master_files mf
        where max_size <> -1
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
        $whitelistedFiles -notcontains $_.fName
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