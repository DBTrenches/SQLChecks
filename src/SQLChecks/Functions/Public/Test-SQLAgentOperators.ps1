Function Test-SQLAgentOperators {
    [cmdletbinding()]
    Param(
        [Parameter(ParameterSetName = "Config", ValueFromPipeline = $true, Position = 0)]
        $Config

        , [Parameter(ParameterSetName = "Values")]
        $ServerInstance

        , [Parameter(ParameterSetName = "Values")]
        $SQLAgentOperators
    )

    if ($PSCmdlet.ParameterSetName -eq "Config") {
        $ServerInstance = $Config.ServerInstance
        $SQLAgentOperators = $Config.SQLAgentOperators
    }

    #Get Target Config
    $TargetOperatorConfig = @(Get-SQLAgentOperators -ServerInstance $serverInstance)

    #Parse SQLChecks Operators config
    $SQLChecksOperatorConfig = @()
    foreach ($OperatorConfig in $SQLAgentOperators) {
  
        $Operator += "Operator="
        $Operator += $OperatorConfig.OperatorName
        $Operator += ",Email="
        $Operator += $OperatorConfig.OperatorEmail
       
        $SQLChecksOperatorConfig += $Operator
        $Operator = ""
    }

    Compare-Object -ReferenceObject $SQLChecksOperatorConfig -DifferenceObject $TargetOperatorConfig | Sort-Object -Property InputObject


}