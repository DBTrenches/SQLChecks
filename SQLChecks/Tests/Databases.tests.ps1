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

Describe "Databases.OversizedIndexes " -Tag Databases.OversizedIndexes {
    BeforeDiscovery {
        [string[]]$Database = Get-DxDatabasesToCheck -EntityName $EntityName -Tag Databases.OversizedIndexes

        $ConfigData = $DxEntity.Databases.OversizedIndexes.AllowList | Select-Object *, @{
            Name = 'FourPartName' 
            Expression = {
                @(
                    $_.Database
                    $_.Schema
                    $_.Table
                    $_.Index
                ) -join '.'
            }
        }

        $OversizedIndexData = @{
            ServerData = Get-DxState Databases.OversizedIndexes @Connect -Database $Database
            ConfigData = $ConfigData 
            KeyName = 'FourPartName'
        }
        New-Variable -Name OversizedIndexCollection -Value (Join-DxConfigAndState @OversizedIndexData)
    }

    It "OversizedIndex: <_.Name> " -ForEach $OversizedIndexCollection {
        $_.ExistsInConfig | Should -BeExactly $_.ExistsOnServer -Because "Oversized indexes that are dropped from the server should be removed from the allowlist. "
    }
}

Describe "Databases.DuplicateIndexes " -Tag Databases.DuplicateIndexes {
    BeforeDiscovery {
        [string[]]$Database = Get-DxDatabasesToCheck -EntityName $EntityName -Tag Databases.DuplicateIndexes

        $ConfigData = $DxEntity.Databases.DuplicateIndexes.AllowList | Select-Object *, @{
            Name = 'FourPartName' 
            Expression = {
                @(
                    $_.Database
                    $_.Schema
                    $_.Table
                    $_.Index
                ) -join '.'
            }
        }

        $DuplicateIndexesData = @{
            ServerData = Get-DxState Databases.DuplicateIndexes @Connect -Database $Database
            ConfigData = $ConfigData 
            KeyName = 'FourPartName'
        }
        New-Variable -Name DuplicateIndexesCollection -Value (Join-DxConfigAndState @DuplicateIndexesData)
    }

    It "DuplicateIndex: <_.Name> " -ForEach $DuplicateIndexesCollection {
        $_.ExistsInConfig | Should -BeExactly $_.ExistsOnServer -Because "Duplicate indexes that are dropped from the server should be removed from the allowlist. "
    }
}