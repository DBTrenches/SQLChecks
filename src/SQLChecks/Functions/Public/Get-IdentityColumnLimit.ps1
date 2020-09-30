Function Get-IdentityColumnLimit {
    [cmdletbinding()]
    Param(
        [Parameter(ParameterSetName = "Config", ValueFromPipeline = $true, Position = 0)]
        $Config

        , [Parameter(ParameterSetName = "Values")]
        [string]
        $ServerInstance

        , [Parameter(ParameterSetName = "Values")]
        [int]
        $PercentThreshold
		
		, [Parameter(ParameterSetName = "Values")]
        [string[]]
        $ExcludedTables

        , [string]
        $Database
    )

    if ($PSCmdlet.ParameterSetName -eq "Config") {
        $ServerInstance = $Config.ServerInstance
        $PercentThreshold = $Config.CheckForIdentityColumnLimit.PercentThreshold
		$ExcludedTables = $Config.CheckForIdentityColumnLimit.ExcludedTables
    }

    $query = @"
DROP TABLE IF EXISTS #tempresults
CREATE TABLE #tempResults
(
DatabaseName varchar(100),
SchemaName varchar(100),
TableName varchar(100),
ColumnName varchar(100),
DataType varchar(128),
LastValue bigint,
MaxValue bigint,
NoRows bigint
)
DECLARE @cmd NVARCHAR(max)


 SET @cmd='

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
    Where id.last_value Is Not Null and databasepropertyex(db_name(),''Updateability'') = ''READ_WRITE'';'

 INSERT INTO #tempResults
         ( DatabaseName,
           SchemaName,
           TableName,
           ColumnName,
           DataType,
           LastValue,
           MaxValue,
           NoRows
         )
 EXEC sys.sp_executesql @cmd=@cmd

select tr.DatabaseName,
       tr.SchemaName,
       tr.TableName,
       tr.ColumnName,
       tr.DataType,
       tr.LastValue,
	   tr.MaxValue,
       tr.NoRows 
from   #tempResults AS tr
cross apply (select Case 
					when tr.LastValue < 0 Then (tr.MaxValue+ cast(tr.LastValue as decimal(19,2)))/tr.MaxValue /*Assumes maxes out at zero*/
					else  cast(tr.LastValue as decimal(19,2))  / tr.MaxValue
			end * 100    as [PercentageFull]) x

where x.PercentageFull >= $PercentThreshold
and tr.DataType not in ('tinyint')
and (tr.DataType <>'bigint'  or (tr.NoRows>tr.MaxValue and tr.LastValue<0 and tr.DataType ='bigint') or (tr.DataType = 'bigint' and tr.LastValue>0));
"@

    Invoke-Sqlcmd -ServerInstance $serverInstance -query $query -Database $Database | Where-Object {
        $ExcludedTables -notcontains $_.DatabaseName+"."+$_.SchemaName+"."+$_.TableName
    } | ForEach-Object {
        [pscustomobject]@{
            Database    = $_.DatabaseName
            Schema      = $_.SchemaName
            Table       = $_.TableName
            Column      = $_.ColumnName
            DataType    = $_.DataType
            LastValue   = $_.LastValue
            MaxValue    = $_.MaxValue
            NoRows      = $_.NoRows
        }
    }
}
