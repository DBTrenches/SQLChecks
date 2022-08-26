#Requires -Modules @{ModuleName='SqlChecks';ModuleVersion='2.0';Guid='998f41a0-c4b4-4ec5-9e11-cb807d98d969'}

# PsScriptAnalyzer reports false positive for $vars defined in `Discovery` not used until `It`
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]

[CmdletBinding()]
Param(
    [string]$EntityName = $DxDefaults.EntityName
)

BeforeAll {
    . $PSScriptRoot/Write-DxTestFileHeader.ps1
    . $PSScriptRoot/Set-DxPesterVariables.ps1
}

BeforeDiscovery {    
    . $PSScriptRoot/Set-DxPesterVariables.ps1
}


Describe "Databases.Indexes.ResumableRebuild.Orphans " -Tag Databases.Indexes.ResumableRebuild.Orphans {
    BeforeAll {
        [string[]]$Database = Get-DxDatabasesToCheck -EntityName $EntityName -Tag Databases.Indexes.ResumableRebuild.Orphans
        $ServerData = Get-DxState Databases.Indexes.ResumableRebuild.Orphans @Connect -Database $Database | Sort-Object _Database
        
    }
    It "Jose is awesome" {
        $ServerData | should -BeNullOrEmpty
    }
}
