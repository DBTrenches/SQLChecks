[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
Param()

$DxEntity = $DxEntityLibrary.$EntityName
$ConnectionString = $DxEntity.ConnectionString
$Connect = @{SqlInstance = $ConnectionString}
