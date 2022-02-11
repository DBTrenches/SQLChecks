

CREATE proc Utility.GetReplicaDatabasesForCheckDB
as
begin;

    --Get all secondary replica databases where backups are running
    with cte
    as (select      d.name as DatabaseName
                   ,ag.IsAvailabilityGroupDatabase
                   ,ag.IsPrimaryReplica
                   ,grp.name as AvailabilityGroup
                   ,databasepropertyex(d.name, 'Updateability') as Updateability
                   ,grp.automated_backup_preference_desc
                   ,sys.fn_hadr_backup_is_preferred_replica(d.name) as IsPreferredReplica
                   ----,mb.is_managed_backup_enabled
        from        sys.databases as d
        left join   sys.dm_hadr_database_replica_states as rs
        on          d.database_id = rs.database_id
        and         rs.is_local = 1

        left join   sys.availability_groups as grp
        on          grp.group_id = rs.group_id
        outer apply
                    (
                        select  case when rs.database_id is null then 0 else 1 end as IsAvailabilityGroupDatabase
                               ,case when rs.is_primary_replica = 1 then 1 else 0 end as IsPrimaryReplica
                    ) as ag
        ----outer apply
        ----            (
        ----                select  is_managed_backup_enabled
        ----                from    msdb.managed_backup.fn_backup_db_config(null) mb
        ----                where   mb.db_name = d.name
        ----                and     mb.is_dropped = 0
        ----                and     mb.is_availability_database = 1
        ----            ) as mb
        where       ag.IsAvailabilityGroupDatabase = 1 --must be an AG database
        and         grp.name not like '%FWD%' --ignore forwarder and DAG AGs
        and         ag.IsPrimaryReplica = 0 --checkdb should only run on secondary
        and         grp.automated_backup_preference_desc = 'secondary' --backup preference for ag should be set to secondary
        and         sys.fn_hadr_backup_is_preferred_replica(d.name) = 1 --this is the preferred replica for backups
        ----and         mb.is_managed_backup_enabled = 1  --managed backup should be enabled
		and			d.name not in
						(
							select  DatabaseName
							from    Utility.DatabaseCheckDBSetting
							where   CheckTypeID = 0 /*DoNotCheck*/
						)
		
		)

		select  cte.DatabaseName  as [name]
		from    cte
		outer apply (select  coalesce(datediff(hour, max(cl.EndTime), getutcdate()), 9999) as HoursSinceLastCheckDB
						from    DBAdmin.dbo.CommandLog cl
						where   cl.CommandType = 'DBCC_CHECKDB'
						and     cl.ErrorNumber = 0
						and     cl.EndTime is not null
						and     cte.DatabaseName = cl.DatabaseName
					) cdb
		where cdb.HoursSinceLastCheckDB > 12
		or cdb.HoursSinceLastCheckDB is null;

end;



