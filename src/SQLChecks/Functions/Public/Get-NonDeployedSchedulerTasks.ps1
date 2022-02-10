Function Get-NonDeployedSchedulerTasks {
    [cmdletbinding()]
    Param(
        [Parameter(ParameterSetName = "Config", ValueFromPipeline = $true, Position = 0)]
        $Config

        , [Parameter(ParameterSetName = "Values")]
        [string]
        $ServerInstance

    )

    if ($PSCmdlet.ParameterSetName -eq "Config") {
        $ServerInstance = $Config.ServerInstance
    }

    $query = @"
exec Utility.GetNonDeployedSchedulerTasks
"@


    Invoke-Sqlcmd -ServerInstance $ServerInstance -Database "DBAdmin" -QueryTimeout 0 -Query $query  

}