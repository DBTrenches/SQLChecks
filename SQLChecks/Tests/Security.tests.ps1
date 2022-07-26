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

    New-Variable -Name Connect -Value @{SqlInstance = $ConnectionString}
}

Describe "Security.SysAdmins " -Tag Security.SysAdmins {
    BeforeDiscovery {
        $SysAdminData = @{
            ConfigData = $DxEntity.Security.SysAdmins 
            ServerData = Get-DxState Security.SysAdmins @Connect 
        }

        New-Variable -Name SysAdminCollection -Value (Join-DxConfigAndState @SysAdminData)
    }

    It "SysAdmin: '<_.Name>' " -ForEach $SysAdminCollection {
        $_.ExistsInConfig | Should -BeTrue
        $_.ExistsOnServer | Should -BeTrue
    }
}

Describe "Service.TempDbConfiguration " -Tag Service.TempDbConfiguration {
    BeforeDiscovery {
        $TempDbConfigurationData = @{
            ConfigData = $DxEntity.Service.TempDbConfiguration 
            ServerData = Get-DxState Service.TempDbConfiguration @Connect 
            KeyName = 'DbName'
        }

        New-Variable -Name TempDbConfiguration -Value (Join-DxConfigAndState @TempDbConfigurationData)
    }

    It "NumberOfFiles: '<_.Config.NumberOfFiles>', TotalSizeMb: '<_.Config.TotalSizeMB>' " -ForEach $TempDbConfiguration {
        $_.ExistsInConfig | Should -BeTrue
        $_.Server.NumberOfFiles | Should -BeExactly $_.Config.NumberOfFiles
        $_.Server.TotalSizeMB | Should -BeExactly $_.Config.TotalSizeMB
    }
}
