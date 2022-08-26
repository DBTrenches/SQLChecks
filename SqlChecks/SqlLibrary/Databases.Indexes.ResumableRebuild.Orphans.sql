/* SQL Query for Databases.Indexes.ResumableRebuild.Orphans */
      select db_name() as DatabaseName
	  ,s.name SchemaName
      ,o.name TableName
      ,iro.name IndexName
      ,iro.state_desc State
	  ,datediff(minute,iro.last_pause_time,getutcdate()) PausedTimeInMinutes
      from sys.index_resumable_operations iro
      join sys.objects o
      on o.object_id = iro.object_id
      join sys.schemas s
      on s.schema_id = o.schema_id
      where iro.state=1