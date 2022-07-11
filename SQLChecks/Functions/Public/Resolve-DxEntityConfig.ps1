function Resolve-DxEntityConfig {
    [CmdletBinding()]
    Param(
        [Parameter()]    
        [string]$EntityName
    )

    $DxEntity = ($DxEntityConfig.$EntityName) | ConvertTo-Json | ConvertFrom-Json

    if(-not $DxEntity){
        Write-Error (
            @(
                "Entity name $EntityName not found in `$DxEntityConfig dictionary. "
                "Please choose an Entity defined in config at $($DxDefaults.EntityConfig.ResolvedFullPath.Path). "
            ) -join ''
        )
    }

    $ProfileName = $Entity.ProfileName
    $DxProfile = $DxProfileConfig.$ProfileName

    if($Profile.Scope -ne $DxEntity.Scope){
        Write-Error (
            @(
                "Configuration error: "
                "Entity '$EntityName' with scope '$($DxEntity.Scope)' "
                "has base profile '$($ProfileName)' with scope '$($DxProfile.Scope)'. "
            ) -join ''
        )
    }

    $ReturnObject = switch ($DxEntity.Scope) {
        'Server' { Resolve-DxServerConfig $DxEntity }
        'AvailabilityGroup' { Resolve-DxAvailabilityGroupConfig $DxEntity }
        'Database' { Resolve-DxDatabaseConfig $DxEntity }
        Default { Write-Error "" }
    }

    return $ReturnObject
}
