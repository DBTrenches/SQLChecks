Push-Location $PSScriptRoot

Add-Type (Get-Content ./SqlChecks/Classes/DxTagGenerator.cs -Raw) 
;;
#region ModuleConfig

$ConfigFile = Get-Item ./Config/SqlChecks.Config.json -ErrorAction SilentlyContinue

if($null -eq $ConfigFile){
    $ModuleConfig = Get-Content ./Config/SqlChecks.Config.Example.json | ConvertFrom-Json
    $ModuleConfig.TemplateConfig.PathExpression = './Config/SqlChecks.Config.json'
    $ModuleConfig | ConvertTo-Json | Set-Content ./Config/SqlChecks.Config.json
    $ConfigFile = Get-Item ./Config/SqlChecks.Config.json 
} else {
    $ModuleConfig = Get-Content $ConfigFile -Raw | ConvertFrom-Json
}

$DxDefaults = $ModuleConfig.Defaults
$DxDefaults.EntityConfig.ResolvedFullPath = Resolve-Path $ModuleConfig.EntityConfig.PathExpression
$DxDefaults.ProfileConfig.ResolvedFullPath = Resolve-Path $ModuleConfig.ProfileConfig.PathExpression
$DxDefaults.TemplateConfig.ResolvedFullPath = Resolve-Path $ModuleConfig.TemplateConfig.PathExpression

Export-ModuleMember -Variable DxDefaults

#endregion ModuleConfig
;;
. ./EntityResolution.ps1
;;
#region SqlLibrary

$SqlLibraryFileCollection = Get-ChildItem -Recurse -Filter *.sql -Path ./SQLChecks/SqlLibrary

$DxSqlLibrary = @{}

foreach($SqlLibraryFile in $SqlLibraryFileCollection){
    $TagName = $SqlLibraryFile.BaseName
    $QueryText = Get-Content $SqlLibraryFile.FullName -Raw
    $DxSqlLibrary.Add($TagName,@{QueryText=$QueryText})
}

Export-ModuleMember -Variable DxSqlLibrary

#endregion SqlLibrary
;; 
#region Functions
$functionFileCollection = Get-ChildItem -Recurse -Filter *.ps1 -Path ./SQLChecks/Functions

foreach($functionFile in $functionFileCollection) {
    . $functionFile.FullName
}

Export-ModuleMember -Alias gxdb 
#endregion Functions
;;
Pop-Location
