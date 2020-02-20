Function Test-ResourceGovernorConfig {
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

    #Get Target Config
    $TargetRGConfig = @(Get-ResourceGovernorConfig -ServerInstance $serverInstance)

    #Parse SQLChecks RG config
    $Properties = $config.ResourceGovernor | Get-Member | Where-Object MemberType -eq NoteProperty | Sort-Object -Property Name -Descending
    $SQLCheckRGConfig = @()
    foreach ($RGConfig in $config.ResourceGovernor) {
  
        foreach ($property in $Properties) {
            [string]$PropertyName = $property.Name
            $RG += $PropertyName + "="
            $RG += $RGConfig.$PropertyName
            $RG += ","
        }        
        $SQLCheckRGConfig += $RG -replace ".$"
        $RG = ""
    }

    Compare-Object -ReferenceObject $SQLCheckRGConfig -DifferenceObject $TargetRGConfig | Sort-Object -Property InputObject


}