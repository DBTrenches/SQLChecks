Function Get-OrphanedResumableIndexRebuild {
    [cmdletbinding()]
    Param(
        [Parameter(ParameterSetName = "Config", ValueFromPipeline = $true, Position = 0)]
        $Config

        , [Parameter(ParameterSetName = "Values")]
        [string]
        $ServerInstance

        , [Parameter(ParameterSetName = "Values")]
        [int]
        $MaxPausedTimeInMinutes
		
        , [string]
        $Database
    )

    if ($PSCmdlet.ParameterSetName -eq "Config") {
        $ServerInstance = $Config.ServerInstance
        $MaxPausedTimeInMinutes = $Config.CheckForOrphanedResumableIndexRebuild.MaxPausedTimeInMinutes
    }

    $query = @"
      select db_name() as DatabaseName
	  ,s.name SchemaName
      ,o.name TableName
      ,iro.name IndexName
      ,iro.state_desc State
	  ,datediff(minute,iro.last_pause_time,getutcdate()) PausedTimeInMinutes
      from sys.index_resumable_operations iro
      join sys.objects o
      on o.object_id = iro.object_id
      join sys.schemas s
      on s.schema_id = o.schema_id
      where iro.state=1 and datediff(minute,iro.last_pause_time,getutcdate()) >=$MaxPausedTimeInMinutes

"@

    Invoke-Sqlcmd -ServerInstance $serverInstance -query $query -Database $Database | ForEach-Object {
        [pscustomobject]@{
            Database            = $_.DatabaseName
            Schema              = $_.SchemaName
            Table               = $_.TableName
            Index               = $_.IndexName
            State               = $_.State
            PausedTimeInMinutes = $_.PausedTimeInMinutes

        }
    }
}

