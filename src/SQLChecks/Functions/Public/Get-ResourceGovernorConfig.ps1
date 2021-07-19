Function Get-ResourceGovernorConfig {
    [cmdletbinding()]
    Param(
        [Parameter(ParameterSetName = "Config", ValueFromPipeline = $true, Position = 0)]
        $Config

        , [Parameter(ParameterSetName = "Values")]
        $ServerInstance
   
    )

    if ($PSCmdlet.ParameterSetName -eq "Config") {
        $ServerInstance = $Config.ServerInstance
    }

    $query = @"
    select  is_enabled as IsEnabled
       ,concat (
            object_schema_name (classifier_function_id)
           ,'.'
           ,object_name (classifier_function_id)) as ClassifierFunction
       ,(   select  drgc.is_reconfiguration_pending
            from    sys.dm_resource_governor_configuration as drgc) as IsReconfigurationPending
    from    sys.resource_governor_configuration;
"@

    Invoke-Sqlcmd -ServerInstance $ServerInstance -query $query -Database master 

    
}