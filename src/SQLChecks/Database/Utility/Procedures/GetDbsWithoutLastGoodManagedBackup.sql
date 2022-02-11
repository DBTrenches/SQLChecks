

CREATE   proc Utility.GetDbsWithoutLastGoodManagedBackup
    @HoursSinceLastGoodBackup int = 48
as
begin

    drop table if exists #ManagedBackupDBs;
    create table #ManagedBackupDBs
    (
        DBName nvarchar(200) not null
    );


insert into #ManagedBackupDBs
select d.name as DatabaseName
from   sys.databases d
where  databasepropertyex(d.name, 'Updateability') = 'READ_WRITE' and d.name not in ( 'tempdb'
                                                                                     ,'model'
                                                                                    ) and not exists (
                                                                                                     select *
                                                                                                     from   Utility.BackUpWhiteList buwl
                                                                                                     where  buwl.DatabaseName = d.name
                                                                                                     );


    select  mb.DBName
           ,abk.LastBackupFinishDate
    from    #ManagedBackupDBs mb
    outer apply
            (
                select  max(ab.backup_finish_date) as LastBackupFinishDate
                from    msdb.managed_backup.fn_available_backups(mb.DBName) ab
                where   ab.backup_type = 'DB' --full backup
                and     ab.backup_finish_date is not null
            ) abk
    where   abk.LastBackupFinishDate is null
    or      abk.LastBackupFinishDate < dateadd(
                                              hour
                                             ,@HoursSinceLastGoodBackup * -1
                                             ,getutcdate()
                                          );

end;

