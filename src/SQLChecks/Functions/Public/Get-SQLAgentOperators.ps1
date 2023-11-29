Function Get-SQLAgentOperators {
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
    select  s.[name] as OperatorName
            ,s.email_address as OperatorEmail
    from    msdb.dbo.sysoperators as s
    where   s.[enabled] = 1;
"@

    $results = Invoke-SQLCMD -TrustServerCertificate -ServerInstance $serverInstance -query $query -Database msdb | Sort-Object -Property OperatorName

    $OperatorConfig = @()
    foreach ($result in $results) {

        $Operator += "Operator="
        $Operator += $result.OperatorName
        $Operator += ",Email="
        $Operator += $result.OperatorEmail
       
        $OperatorConfig += $Operator
        $Operator = ""
    }

    return $OperatorConfig

    
}