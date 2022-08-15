#Requires -Modules @{ModuleName='SqlChecks';ModuleVersion='2.0';Guid='998f41a0-c4b4-4ec5-9e11-cb807d98d969'}

# PsScriptAnalyzer reports false positive for $vars defined in `Discovery` not used until `It`
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]

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

Describe "Service.TraceFlags " -Tag Service.TraceFlags {
    BeforeDiscovery {
        $TraceFlagData = @{
            ServerData = Get-DxState Service.TraceFlags @Connect 
            ConfigData = $DxEntity.Service.TraceFlags 
            KeyName = 'TraceFlag'
        }
        $TraceFlagCollection = Join-DxConfigAndState @TraceFlagData
    }

    It "TraceFlag test is running" -ForEach $TraceFlagCollection[0] {
        ($_.ExistsInConfig).Count | Should -BeExactly 1 -Because "In order to confirm the test ran, an empty object is returned from `Join-DxConfigAndState` when there is a null set on both server and config "
    }
    Context "TraceFlag: <_.Name> " -ForEach $TraceFlagCollection {
        It "Is in config " {
            $_.ExistsInConfig | Should -BeTrue -Because "We should have all TFs documented in Config. "
        }
        It "Is deployed " {
            $_.ExistsOnServer | Should -BeTrue -Because "All config TFs should be applied "
        }
    }
}

Describe "Service.SysConfigurations " -Tag Service.SysConfigurations, SpConfigure {
    BeforeDiscovery {
        $SpConfigData = @{
            ConfigData = $DxEntity.Service.SysConfigurations 
            ServerData = Get-DxState Service.SysConfigurations @Connect 
        }

        $SpConfigCollection = Join-DxConfigAndState @SpConfigData
    }

    It "SysConfiguration: '<_.Name>' " -ForEach $SpConfigCollection {
        $_.ExistsInConfig | Should -BeTrue
        $_.ExistsOnServer | Should -BeTrue
        $_.Server.Value | Should -BeExactly $_.Config.Value
        $_.Server.ValueInUse | Should -BeExactly $_.Server.Value
    }
}

Describe "Service.TempDbConfiguration " -Tag Service.TempDbConfiguration {
    BeforeDiscovery {
        $TempDbConfigurationData = @{
            ConfigData = $DxEntity.Service.TempDbConfiguration 
            ServerData = Get-DxState Service.TempDbConfiguration @Connect 
            KeyName = 'DbName'
        }

        $TempDbConfiguration = Join-DxConfigAndState @TempDbConfigurationData
    }

    It "NumberOfFiles: '<_.Config.NumberOfFiles>' " -ForEach $TempDbConfiguration {
        $_.ExistsInConfig | Should -BeTrue
        $_.Server.NumberOfFiles | Should -BeExactly $_.Config.NumberOfFiles
    }
    
    It "TotalSizeMb: '<_.Config.TotalSizeMB>' " -ForEach $TempDbConfiguration {
        $_.ExistsInConfig | Should -BeTrue
        $_.Server.TotalSizeMB | Should -BeExactly $_.Config.TotalSizeMB
    }
}
