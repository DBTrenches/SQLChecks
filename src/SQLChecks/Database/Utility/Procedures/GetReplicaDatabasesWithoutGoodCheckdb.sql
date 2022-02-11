
create proc Utility.GetReplicaDatabasesWithoutGoodCheckdb @days int  --find database without good checkdb greater than this value
as
begin

    drop table if exists #Dbs;

    create table #Dbs
    (
        ID           int           identity(1, 1) not null
       ,DatabaseName nvarchar(200) not null
	   ,DaysSinceLastGoodCheckDB int not null default 9999
	   ,LastGoodCheckDBDate datetime2(2) null
    )


    insert into #Dbs (DatabaseName)
    exec Utility.GetReplicaDatabasesForCheckDB;


    declare @startID int =
            (
                select  min(ID) from #Dbs
            );
    declare @endID int =
            (
                select  max(ID) from #Dbs
            );
    declare @DatabaseName nvarchar(200);
    declare @daysSinceCheckDB int;
	declare @lastGoodCheckDBDate datetime2(2);

    while @startID <= @endID
    begin

		--clear variables
        set @DatabaseName = null; 
        set @daysSinceCheckDB = null;
		set @lastGoodCheckDBDate = null;


        set @DatabaseName =
        (
            select  DatabaseName from   #Dbs where  ID = @startID
        );


        select      @daysSinceCheckDB = coalesce(datediff(day, max(EndTime), getutcdate()), 9999),
					@lastGoodCheckDBDate = max(EndTime)
        from        DBAdmin.dbo.CommandLog
        where       CommandType = 'DBCC_CHECKDB'
        and         ErrorNumber = 0
        and         EndTime is not null
        and         DatabaseName = @DatabaseName
        group by    DatabaseName;

        update  #Dbs
        set     DaysSinceLastGoodCheckDB = coalesce(@daysSinceCheckDB, 9999)
				,LastGoodCheckDBDate = @lastGoodCheckDBDate
        where   ID = @startID
        and     DatabaseName = @DatabaseName;



        set @startID = @startID + 1;

    end;


    select  DatabaseName
           ,LastGoodCheckDBDate
		   ,DaysSinceLastGoodCheckDB
    from    #Dbs
    where   DaysSinceLastGoodCheckDB > @days;



end;

