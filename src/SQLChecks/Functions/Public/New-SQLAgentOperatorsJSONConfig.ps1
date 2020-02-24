Function New-SQLAgentOperatorsJSONConfig {
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
    declare @Operator_JSON nvarchar(max) =
    (
        select  s.[name] as OperatorName
               ,s.email_address as OperatorEmail
        from    msdb.dbo.sysoperators as s
        where   s.[enabled] = 1
        order by s.[name] asc
        for json path, root('SQLAgentOperators')
    );

    select  @Operator_JSON as SQLAgentOperatorsOutput;
"@

    $results = Invoke-Sqlcmd -ServerInstance $ServerInstance -query $query -Database msdb -MaxCharLength 1000000

    return $results.SQLAgentOperatorsOutput


}