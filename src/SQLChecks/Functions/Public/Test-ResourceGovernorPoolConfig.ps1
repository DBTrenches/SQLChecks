Function Test-ResourceGovernorPoolConfig {
    [cmdletbinding()]
    Param(
        [Parameter(ParameterSetName = "Config", ValueFromPipeline = $true, Position = 0)]
        $Config

        , [Parameter(ParameterSetName = "Values")]
        $ServerInstance

        , [Parameter(ParameterSetName = "Values")]
        $ResourceGovernorPoolConfig
    )

    if ($PSCmdlet.ParameterSetName -eq "Config") {
        $ServerInstance = $Config.ServerInstance
        $ResourceGovernorPoolConfig = $Config.ResourceGovernorPools
    }

    #Get Target Config
    $TargetRGConfig = @(Get-ResourceGovernorPoolConfig -ServerInstance $serverInstance)

    #Parse SQLChecks RG config
    $Properties = $ResourceGovernorPoolConfig | Get-Member | Where-Object MemberType -EQ NoteProperty | Sort-Object -Property Name -Descending
    $SQLCheckRGConfig = @()
    foreach ($RGConfig in $ResourceGovernorPoolConfig) {
  
        foreach ($property in $Properties) {
            [string]$PropertyName = $property.Name
            $RG += $PropertyName + "="
            $RG += $RGConfig.$PropertyName
            $RG += ","
        }        
        $SQLCheckRGConfig += $RG -replace ".$"
        $RG = ""
    }

    Compare-SqlChecks -ReferenceObject $SQLCheckRGConfig -DifferenceObject $TargetRGConfig
}