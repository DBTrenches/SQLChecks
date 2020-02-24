Function Get-SQLEndpoints {
    [cmdletbinding()]
    Param(
        [Parameter(ParameterSetName = "Config", ValueFromPipeline = $true, Position = 0)]
        $Config

        , [Parameter(ParameterSetName = "Values")]
        $ServerInstance

        , [Parameter(ParameterSetName = "Values")]
        $SQLEndpoints
   
    )

    if ($PSCmdlet.ParameterSetName -eq "Config") {
        $ServerInstance = $Config.ServerInstance
        $SQLEndpoints = $Config.SQLEndpoints
    }

    $query = @"
    select  e.[name] as EndPointName
    from    sys.endpoints as e
    where   e.state_desc = 'STARTED';
"@

    $results = Invoke-Sqlcmd -ServerInstance $serverInstance -query $query -Database master 
    $SQLEndpoints | Where-Object {$results.EndPointName -notcontains $_}
    
}