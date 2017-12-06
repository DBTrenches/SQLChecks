Function Get-TLogGrowthSizeAboveLimit {
    [cmdletbinding()]
    Param(
        [string] $ServerInstance,
	[int] $ExpectedMaxTLogAutoGrowthInKB
    )

    $query = "SELECT  COUNT(*) AS NumberofDbsOverMaxTLogAutoGrowthInKB
    FROM    sys.master_files s
            JOIN sys.databases AS d ON s.database_id = d.database_id
    WHERE   ( d.replica_id IS NULL
              OR EXISTS ( SELECT    *
                          FROM      sys.availability_databases_cluster AS adc
                                    JOIN sys.dm_hadr_availability_replica_states
                                    AS dhars ON dhars.group_id = adc.group_id
                          WHERE     dhars.role = 1
                                    AND adc.database_name = d.name )
            )
            AND s.type = 1
            AND ( s.growth * 8 ) >" + $ExpectedMaxTLogAutoGrowthInKB +";"

    return (Invoke-Sqlcmd -ServerInstance $serverInstance -query $query).NumberofDbsOverMaxTLogAutoGrowthInKB
}

