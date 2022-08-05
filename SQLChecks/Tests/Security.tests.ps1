#Requires -Modules @{ModuleName='SqlChecks';ModuleVersion='2.0';Guid='998f41a0-c4b4-4ec5-9e11-cb807d98d969'}

[CmdletBinding()]
Param(
    [string]$EntityName = $DxDefaults.EntityName
)

BeforeAll {
    if ($PSBoundParameters.Keys -contains 'EntityName') {
        Write-Verbose "User-selected entity will be used. "
    }
    else {
        Write-Verbose "Default entity will be used. "
    }

    Write-Host "Selected entity is '$EntityName' "
    Write-Host "The connection string to be used is '$($DxEntityLibrary.$EntityName.ConnectionString)' "
}

BeforeDiscovery {    
    $DxEntity = $DxEntityLibrary.$EntityName

    $ConnectionString = $DxEntity.ConnectionString

    $Connect = @{SqlInstance = $ConnectionString}
}

Describe "Security.SysAdmins " -Tag Security.SysAdmins {
    BeforeDiscovery {
        $SysAdminData = @{
            ConfigData = $DxEntity.Security.SysAdmins 
            ServerData = Get-DxState Security.SysAdmins @Connect 
        }

        $SysAdminCollection = Join-DxConfigAndState @SysAdminData
    }

    It "SysAdmin: '<_.Name>' " -ForEach $SysAdminCollection {
        $_.ExistsInConfig | Should -BeTrue
        $_.ExistsOnServer | Should -BeTrue
    }
}
