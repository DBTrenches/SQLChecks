select database_id
      ,[file_id]
      ,[type]
      ,[type_desc]
      ,[state]
      ,state_desc
      ,growth
      ,size_mb=try_convert(float,(try_cast(size as bigint)*8192.)/power(1024,2)) 
      ,max_size
      ,[db_name]=db_name(database_id)
      ,f_name=[name]
      ,f_path=physical_name
from sys.master_files 
where growth = 0;
