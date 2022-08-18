#Requires -Modules @{ModuleName='SqlChecks';ModuleVersion='2.0';Guid='998f41a0-c4b4-4ec5-9e11-cb807d98d969'}

<#
.SYNOPSIS
    Set common variables for a SqlChecks test file parent Scope

.DESCRIPTION
    Dot-source this file to turn the below three lines (used twice per file because
    of Pester scoping issues) into a 1-liner (x2). Dot-sourcing allows the caller 
    to share the scope of this file and thus inherit the values for the variables set 
    here. DO NOT use the Param() block. It is required for PSSA suppression but will
    highjack usage. `$EntityName` should be in scope in the caller.

.EXAMPLE
    # from a Checks/SqlChecks.tests.ps1 file
    . $PSScriptRoot/Set-DxPesterVariables.ps1
#>

[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
Param()

$DxEntity = $DxEntityLibrary.$EntityName
$ConnectionString = $DxEntity.ConnectionString
$Connect = @{SqlInstance = $ConnectionString}
