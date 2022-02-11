-- depends on https://github.com/andrewalumkal/SQLBlobShipping
-- for dbo.SQLBlobShippingLog

create   proc Utility.GetLastRestoredBackup
    @TargetRestoreServer              varchar(100)
   ,@DataBase                         varchar(100)
   ,@HoursSinceLastGoodRestoredBackup int
as
begin
    select      top 1   l.SourceDatabase DBName
                       ,l.RestoreFinishDate LastRestoredBackupFinishDate
    from        dbo.SQLBlobShippingLog l
    where       l.SourceDatabase = @DataBase
    and         l.TargetServer = @TargetRestoreServer
	and			l.RestoreError = 0
	and			l.RestoreErrorMessage is null
    and         l.RestoreFinishDate >= dateadd(
                                                  hour
                                                 ,(-1
                                                   * @HoursSinceLastGoodRestoredBackup
                                                  )
                                                 ,getutcdate()
                                              )
    order by    l.RestoreStartDate desc;
end;

