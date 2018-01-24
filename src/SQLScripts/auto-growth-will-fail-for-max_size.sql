;with fileGrowth as (
    select database_id
          ,[file_id]
          ,[type]
          ,[type_desc]
          ,[state]
          ,state_desc
          ,growth
          ,is_percent_growth
          ,growthMb=
               case is_percent_growth 
                   when 1 then (growth/100.)*(try_cast(size as bigint)*8192.)/power(1024,2) 
                   else (try_cast(growth as bigint)*8192.)/power(1024,2) 
               end
          ,sizeMb=(try_cast(size as bigint)*8192.)/power(1024,2) 
          ,maxSizeMb=(try_cast(nullif(max_size,-1) as bigint)*8192.)/power(1024,2) 
          ,dbName=db_name(database_id)
          ,fName=[name]
          ,fPath=physical_name
    from sys.master_files mf
    where max_size <> -1
)
select @@servername as srvr
      ,dbName
      ,fName
      ,growthMb=try_convert(float,growthMb)
      ,is_percent_growth
      ,curSizeMb=try_convert(float,sizeMb)
      ,maxSizeMb=try_convert(float,maxSizeMb)
      ,nextGrowthSizeMb=try_convert(float,sizeMb+growthMb)
      ,cmd='alter database ['+dbName+'] modify file (name=N'''+fName+''',maxsize='+try_cast(ceiling(sizeMb+growthMb+1) as varchar)+'mb);'
      ,fPath
      ,database_id
      ,[file_id]
      ,[type]
      ,[type_desc]
      ,[state]
      ,state_desc
from fileGrowth fg
where (sizeMb+growthMb)>maxSizeMb;
