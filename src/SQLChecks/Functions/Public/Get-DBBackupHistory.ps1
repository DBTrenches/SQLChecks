Function Get-DBBackupHistory {
    [cmdletbinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $ServerInstance,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $DatabaseName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [Int]
        $HistoryHours

    )

    $HoursAgo = $HistoryHours * -1

    $query = @"
    select      s.database_name
           ,case s.[type] when 'D' then 'Full'
                          when 'I' then 'Diff'
                          when 'L' then 'Log' end as BackupType
           ,m.physical_device_name
           ,s.backup_start_date
           ,s.backup_finish_date
           ,s.server_name
           ,s.recovery_model
           ,cast(s.first_lsn as varchar(50)) as first_lsn
           ,cast(s.last_lsn as varchar(50)) as last_lsn
    from        msdb.dbo.backupset s
    inner join  msdb.dbo.backupmediafamily m
    on          s.media_set_id = m.media_set_id
    where       s.database_name = '$DatabaseName'
    and         s.backup_finish_date > dateadd(hour, $HoursAgo, getutcdate())
    order by    s.backup_finish_date desc;
"@


        
    $DBOutput = Invoke-Sqlcmd -ServerInstance $ServerInstance -Database msdb -Query $query -QueryTimeout 60
    return $DBOutput

    
}