function Resolve-DxEntityConfig {
    [CmdletBinding()]
    Param(
        [Parameter()]    
        [string]$EntityName
    )

    $DxEntity = $DxEntityConfig.$EntityName

    if($null -eq $DxEntity){
        Write-Error (
            @(
                "Entity name $EntityName not found in `$DxEntityConfig dictionary. "
                "Please choose an Entity defined in config at $($DxDefaults.EntityConfig.ResolvedFullPath.Path). "
            ) -join ''
        )
    }

    $ProfileName = $DxEntity.ProfileName
    $DxProfile = Resolve-DxProfile $ProfileName

    if($DxProfile.Scope -ne $DxEntity.Scope){
        Write-Error (
            @(
                "Configuration error: "
                "Entity '$EntityName' with scope '$($DxEntity.Scope)' "
                "has base profile '$($ProfileName)' with scope '$($DxProfile.Scope)'. "
            ) -join ''
        )
    }

    switch ($DxEntity.Scope) {
        'Server' {
            $DxProfile.ConnectionString = $DxEntity.ConnectionString
        }
        'AvailabilityGroup' { }
        'Database' { }
        Default { Write-Error "Yooohnoooooh" }
    }

    $ReturnObject = switch ($DxEntity.Scope) {
        'Server' { Resolve-DxServerConfig -DxEntity $DxEntity -DxProfile $DxProfile }
        'AvailabilityGroup' { Resolve-DxAvailabilityGroupConfig $DxEntity }
        'Database' { Resolve-DxDatabaseConfig $DxEntity }
        Default { Write-Error "yarglebargle" }
    }

    return $ReturnObject
}
