select mf.database_id
      ,mf.[file_id]
      ,mf.[type]
      ,mf.[type_desc]
      ,mf.[state]
      ,mf.state_desc
      ,mf.growth
      ,mf.is_percent_growth
      ,sizeMb=(try_cast(mf.size as bigint)*8192.)/power(1024,2) 
      ,mf.max_size
      ,dbName=db_name(mf.database_id)
      ,fName=mf.[name]
      ,fPath=mf.physical_name
from sys.master_files mf
where mf.growth = 0;
