Function Get-DBSettings {
    [cmdletbinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $ServerInstance,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $DatabaseName

    )

    $query = @"
    select      d.[name] as DatabaseName
            ,ag.IsAvailabilityGroupDatabase
            ,ag.IsPrimaryReplica
            ,grp.name as AvailabilityGroup
            ,databasepropertyex(d.name, 'Updateability') as Updateability
            ,d.State_Desc
    from        sys.databases as d
    left join   sys.dm_hadr_database_replica_states as rs
    on          rs.database_id = d.database_id
    and         rs.is_local = 1
    left join sys.availability_groups as grp
    on grp.group_id = rs.group_id
    outer apply
        (
            select  case when rs.database_id is null then 0 else 1 end as IsAvailabilityGroupDatabase
                    ,case when rs.is_primary_replica = 1 then 1 else 0 end as IsPrimaryReplica
        ) as ag
    where d.name = '$DatabaseName';
"@


        
    $DBOutput = Invoke-Sqlcmd -ServerInstance $ServerInstance -Database master -Query $query -QueryTimeout 60
    return $DBOutput

    
}