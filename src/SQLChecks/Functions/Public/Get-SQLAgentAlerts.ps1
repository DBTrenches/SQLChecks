Function Get-SQLAgentAlerts {
    [cmdletbinding()]
    Param(
        [Parameter(ParameterSetName = "Config", ValueFromPipeline = $true, Position = 0)]
        $Config

        , [Parameter(ParameterSetName = "Values")]
        $ServerInstance

        , [Parameter(ParameterSetName = "Values")]
        $SQLAgentAlerts
   
    )

    if ($PSCmdlet.ParameterSetName -eq "Config") {
        $ServerInstance = $Config.ServerInstance
        $SQLAgentAlerts = $Config.SQLAgentAlerts
    }

    $query = @"
    select      [name] as AlertName
    from        msdb.dbo.sysalerts
    where       [enabled] = 1
    and         [has_notification] = 1
    order by    [name];
"@

    $results = Invoke-Sqlcmd -ServerInstance $serverInstance -Query $query -Database msdb 

    Compare-SqlChecks -ReferenceObject $results.AlertName -DifferenceObject $SQLAgentAlerts
}