Function Get-SqlChecksFromConfig {
    [cmdletbinding()]
    Param(
        [Parameter(ParameterSetName = "Config", ValueFromPipeline = $true, Position = 0)]
        $Config
    )
    $Config | Get-Member -Type NoteProperty | Where-Object {
        $_.Name -notin ("ServerInstance", "DatabasesToCheck", "AvailabilityGroup")
    } | Select-Object -ExpandProperty Name
}