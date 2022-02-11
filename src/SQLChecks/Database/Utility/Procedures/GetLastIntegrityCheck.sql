-- depends on RestoreDBCheck powershell module
-- for dbo.CheckDBLog

create   proc Utility.GetLastIntegrityCheck
    @TargetRestoreServer              varchar(100)
   ,@DataBase                         varchar(100)
   ,@HoursSinceLastGoodIntegrityCheck int
as
begin
    select      top 1   l.SourceDatabase DBName
                       ,l.CheckDBFinishDate LastIntegrityCheckFinishDate
    from        dbo.CheckDBLog l
    where       l.SourceDatabase = @DataBase
    and         l.TargetServer = @TargetRestoreServer
	and			l.CheckDBError = 0
	and			l.CheckDBErrorMessage is null
    and         l.CheckDBFinishDate >= dateadd(
                                                  hour
                                                 ,(-1
                                                   * @HoursSinceLastGoodIntegrityCheck
                                                  )
                                                 ,getutcdate()
                                              )
    order by    l.CheckDBStartDate desc;
end;
