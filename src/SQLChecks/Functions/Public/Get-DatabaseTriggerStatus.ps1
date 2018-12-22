Function Get-DatabaseTriggerStatus {
    [cmdletbinding()]
    Param(
        [Parameter(ParameterSetName = "Config", ValueFromPipeline = $true, Position = 0)]
        $Config

        , [Parameter(ParameterSetName = "Values")]
        $ServerInstance

        , [Parameter(ParameterSetName = "Values")]
        [string]
        $TriggerName,

        [string]
        $Database
    )

    if ($PSCmdlet.ParameterSetName -eq "Config") {
        $ServerInstance = $Config.ServerInstance
        $TriggerName = $Config.MustHaveDDLTrigger.TriggerName
    }

    $query = @"
    select count(*) as TriggerCount
    from sys.triggers as t
    where t.name = '$TriggerName'
    and t.is_disabled = 0
"@

    $result = Invoke-Sqlcmd -ServerInstance $serverInstance -query $query -Database $Database
    if ($result.TriggerCount -eq 0) {
        $false
    }
    else {
        $true
    }
}