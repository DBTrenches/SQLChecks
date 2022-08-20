function New-DxCheck {
<#
.SYNOPSIS
    Creates placeholder components needed to initialise a new SqlCheck

.DESCRIPTION
    1. Given an input $Tag that does not already exist in the Tag Collection
    2. Add that Tag to the Collection (defined in the DxTagGenerator class file)
    3. Add a (blank) SqlLibrary file for the Tag and open it for editting in VSCode
    4. Add a stub test snippet to the appropriate .tests.ps1 file
    5. TODO: handle for adding config

.PARAMETER Scalar
    By default, this will create a stub for a complex data-driven test. If you want 
    a simple (one-row, single-attribute) test, you can specify `-Scalar` to get the 
    alternate test stub syntax. BEWARE - scalar tests require data to be retrieved
    in the `Run` phase and may require a `BeforeAll{}` block add to the top of the 
    tests.ps1 file
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Tag,

        [Parameter()]
        [switch]
        $Scalar
    )

    # 1. Is the tag unique and new?
    if($Tag -In [DxTagGenerator]::New().GetValidValues()){
        Write-Error "Chosen tag '$Tag' is already configured. Choose a different name. "
        return
    }

    Push-Location $PSScriptRoot/..

    # 2. add the tag to the collection
    [Collections.ArrayList]$ClassFile = Get-Content Classes/DxTagGenerator.cs
    $InsertStart = $ClassFile.IndexOf("        {")
    $ClassFile.Insert(1 + $InsertStart,"            `"$Tag`",")
    $ClassFile | Set-Content Classes/DxTagGenerator.cs

    # 3. add a (blank) SqlLibrary file and open for editing
    New-Item -ItemType File -Path "SqlLibrary/$($Tag).sql" -Value "/* SQL Query for $Tag */"
    code --add "SqlLibrary/$($Tag).sql" 

    # 4. add a stub test and open for editting
    $QueryDomain = ($Tag -split '\.')[0]
    $EndOfTag = $Tag -replace "$QueryDomain."
    $TestFile = Get-ChildItem "../Checks/${QueryDomain}.tests.ps1"
    if(-not $TestFile){
        $header = @"
#Requires -Modules @{ModuleName='SqlChecks';ModuleVersion='2.0';Guid='998f41a0-c4b4-4ec5-9e11-cb807d98d969'}

# PsScriptAnalyzer reports false positive for `$vars defined in `BeforeDiscovery` not used until `It`
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]

[CmdletBinding()]
Param(
    [string]`$EntityName = `$DxDefaults.EntityName
)

BeforeAll {
    . `$PSScriptRoot/Set-DxPesterVariables.ps1
    if (`$PSBoundParameters.Keys -contains 'EntityName') {
        Write-Verbose "User-selected entity will be used. "
    }
    else {
        Write-Verbose "Default entity will be used. "
    }
    Write-Host "Selected entity is '`$EntityName' "
    Write-Host "The connection string to be used is '`$(`$DxEntityLibrary.`$EntityName.ConnectionString)' "
}

BeforeDiscovery {
    . `$PSScriptRoot/Set-DxPesterVariables.ps1
}
        
"@
        $TestFile = New-Item -ItemType File -Name "../Checks/${QueryDomain}.tests.ps1" -Value $header
    }
    $footer_DataDriven = @"

Describe "${Tag} " -Tag ${Tag} {
    BeforeDiscovery {
        Initialize-DxCheck ${Tag}
    }
    Context "${EndOfTag}: '<_.Name>' " -ForEach `$Collection {
        It "Exists on the server " {
            `$_.ExistsOnServer | Should -BeTrue -Because "${EndOfTag} values should be remove from config when obsolete. "
        }
        It "Exists in config " {
            `$_.ExistsInConfig | Should -BeTrue -Because "${EndOfTag} entries that exist on the server should be registered in config. " 
        }
<# #ADD Other logical tests here!
        It "Has the correct value for 'ColumnName' (<_.Config.ColumnName>) " {
            `$_.Server.ColumnName | Should -BeExactly `$_.Config.ColumnName
        }
#>
    }
}
"@
    $footer_Scalar = @"

Describe "${Tag} " -Tag ${Tag} {
    BeforeAll {
        # this dot-source can be removed if there is a script-level `BeforeAll{}` copy
        . `$PSScriptRoot/Set-DxPesterVariables.ps1
        `$ServerValue = (Get-DxState ${Tag} @Connect).NumErrorLogs
        `$ConfigValue = `$DxEntityLibrary.`$EntityName.${Tag}
    }
    It "${EndOfTag}: `$(`$DxEntityLibrary.`$EntityName.${Tag}) " {
        `$ServerValue | Should -BeExactly `$ConfigValue
        `$ConfigValue | Should -Not -BeNullOrEmpty
    }
}
"@
    $footer = switch ($Scalar) {
        $true { $footer_Scalar }
        $false { $footer_DataDriven }
    }
    Add-Content -Path $TestFile -Value $footer
    code --add $TestFile

    # 5. TODO: handle for adding config

    Pop-Location
}
