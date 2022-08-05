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
select
    db_name() as DatabaseName,
    schema_name(o.schema_id) SchemaName,
    o.name TableName,
    id.name ColumnName,
    t.name DataType,
    cast(id.last_value as bigint) LastValue,
    case 
        when t.name = 'tinyint'  then 255
        when t.name = 'smallint' then 32767
        when t.name = 'int'      then 2147483647
        when t.name = 'bigint'   then 9223372036854775807 
    end as MaxValue,
    p.rows
from sys.identity_columns id
join sys.objects o on o.object_id = id.object_id
join sys.types as t on id.system_type_id = t.system_type_id
join (
    select
        object_id,
        sum(rows) rows
    from sys.partitions
    group by object_id
) p on p.object_id = id.object_id
where id.last_value is not null
  and databasepropertyex(db_name(), 'Updateability') = 'READ_WRITE';

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
where x.PercentageFull >= 80
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