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
        [string[]]$Database = $DxEntity.DatabasesToCheck

        if(($Database.Count -eq 1) -and ($Database[0].Substring(0,1) -eq '@')){
            $Label = $Database
            $Database = switch ($Label) {
                "@LocalOnly" { (Invoke-SqlCmd2 -ServerInstance $ConnectionString -Query "select d.[name] from sys.databases as d where not exists (select database_name from sys.availability_databases_cluster as adc where adc.[database_name] = d.[name]);").name }
                "@AgOnly" { (Invoke-SqlCmd2 -ServerInstance $ConnectionString -Query "select distinct database_name from sys.availability_databases_cluster;").database_name }
                "@All" { @("*") }
                Default {}
            }
        }

        $DxEntity.Databases.OversizedIndexes.ExcludedDatabases | ForEach-Object {
            $Database += "-$_"
        } 
        
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
        $_.ExistsInConfig | Should -BeTrue 
        $_.ExistsOnServer | Should -BeTrue -Because "Oversized indexes that are dropped from the server should be removed from the allowlist. "
    }    
}
