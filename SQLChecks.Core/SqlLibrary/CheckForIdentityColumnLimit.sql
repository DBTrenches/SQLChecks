drop table if exists #tempresults;

create table #tempResults (
    DatabaseName varchar(100),
    SchemaName   varchar(100),
    TableName    varchar(100),
    ColumnName   varchar(100),
    DataType     varchar(128),
    LastValue    bigint,
    MaxValue     bigint,
    NoRows       bigint
);

declare @cmd nvarchar(max);

set @cmd = N'

    Select db_name() as DatabaseName,
	       schema_name (o.schema_id) SchemaName,
		   o.name TableName,
           id.name ColumnName,
           t.name DataType,
           cast(id.last_value As bigint) LastValue,
           case 
             when t.name = ''tinyint''  Then 255 
             When t.name = ''smallint''  Then 32767 
             When t.name = ''int''       Then 2147483647 
             When t.name = ''bigint''    Then 9223372036854775807
           end MaxValue,
		   p.rows
    from  sys.identity_columns id
	join  sys.objects o
	on    o.object_id = id.object_id
    Join  sys.types As t
    on    id.system_type_id = t.system_type_id
	join  (select object_id , sum(rows) rows from sys.partitions group by object_id) p
	on    p.object_id = id.object_id
    Where id.last_value Is Not Null and databasepropertyex(db_name(),''Updateability'') = ''READ_WRITE'';';

insert into #tempResults (
    DatabaseName,
    SchemaName,
    TableName,
    ColumnName,
    DataType,
    LastValue,
    MaxValue,
    NoRows
)
exec sys.sp_executesql @cmd = @cmd;

select
    tr.DatabaseName,
    tr.SchemaName,
    tr.TableName,
    tr.ColumnName,
    tr.DataType,
    tr.LastValue,
    tr.MaxValue,
    tr.NoRows
from #tempResults as tr
cross apply (
    select
        case when tr.LastValue < 0 then
        (tr.MaxValue + tr.LastValue)
        / try_convert(decimal(21, 2), tr.MaxValue) / 2 /*Assumes maxes out at cap, not zero*/
             else cast(tr.LastValue as decimal(19, 2)) / tr.MaxValue end
        * 100 as [PercentageFull]
) x
where x.PercentageFull >= @PercentThreshold
  and tr.DataType not in ( 'tinyint' )
  and (
      tr.DataType <> 'bigint'
     or (
         tr.NoRows > tr.MaxValue
      and tr.LastValue < 0
      and tr.DataType = 'bigint'
     )
     or (
         tr.DataType = 'bigint'
      and tr.LastValue > 0
     )
  );