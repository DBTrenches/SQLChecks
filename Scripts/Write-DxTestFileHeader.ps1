#Requires -Modules @{ModuleName='SqlChecks';ModuleVersion='2.0';Guid='998f41a0-c4b4-4ec5-9e11-cb807d98d969'}

<#
.EXAMPLE
    # from a file in the Checks directory. e.g. Checks/SqlAgent.Tests.ps1
    . $PSScriptRoot/../Scripts/Write-DxTestFileHeader.ps1
#>

if ($PSBoundParameters.Keys -contains 'EntityName') {
    Write-Verbose "User-selected entity will be used. "
}
else {
    Write-Verbose "Default entity will be used. "
}

Write-Host "Selected entity is '$EntityName' "
Write-Host "The connection string to be used is '$($DxEntityLibrary.$EntityName.ConnectionString)' "
