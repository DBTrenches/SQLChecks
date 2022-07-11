Push-Location $PSScriptRoot

Add-Type (Get-Content ./SqlChecks/Classes/DxTagGenerator.cs -Raw) 
;;
#region ModuleConfig

$ConfigFile = Get-Item ./Config/Module/SqlChecks.Config.json -ErrorAction SilentlyContinue

if($null -eq $ConfigFile){
    $ModuleConfig = Get-Content ./Config/Module/SqlChecks.Config.Example.json | ConvertFrom-Json
    $ModuleConfig.TemplateConfig.PathExpression = './Config/Module/SqlChecks.Config.json'
    $ModuleConfig | ConvertTo-Json | Set-Content ./Config/Module/SqlChecks.Config.json
    $ConfigFile = Get-Item ./Config/Module/SqlChecks.Config.json 
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
#region TemplateConfig

$DxTemplateConfig = @{}

Push-Location $ModuleConfig.TemplateConfig.PathExpression

    foreach($file in (Get-ChildItem . -Recurse -Include *.json,*.csv)) {
        $ConfigObject = switch($file.Extension){
            '.json' {Get-Content $file -Raw | ConvertFrom-Json}
            '.csv' {Get-Content $file -Raw | ConvertFrom-Csv}
        }
        
        $RootKey = $file.Directory.Name
        
        if(-not $DxTemplateConfig.$RootKey){
            $DxTemplateConfig.Add($RootKey,@{})
        }
        $DxTemplateConfig.$RootKey.Add($file.BaseName,$ConfigObject)
    }

Pop-Location

$DxTemplateConfig.Add('Class',@{})

Get-ChildItem ./SqlChecks/Classes -Filter *.json | ForEach-Object {
    $ConfigObject = Get-Content $_ -Raw | ConvertFrom-Json

    $DxTemplateConfig.Class.Add($_.BaseName,$ConfigObject)
}

Export-ModuleMember -Variable DxTemplateConfig

#endregion TemplateConfig
;;
#region ProfileConfig

$DxProfileConfig = @{}

Push-Location $ModuleConfig.ProfileConfig.PathExpression

    Get-ChildItem . -Recurse -Include *.json | ForEach-Object {
        $ConfigObject = Get-Content $_ -Raw | ConvertFrom-Json
        
        $DxProfileConfig.Add($_.BaseName,$ConfigObject)
    }

Pop-Location

Export-ModuleMember -Variable DxProfileConfig

#endregion ProfileConfig
;;
#region EntityConfig

$DxEntityConfig = @{}

Push-Location $ModuleConfig.EntityConfig.PathExpression

    Get-ChildItem . -Recurse -Include *.json | ForEach-Object {
        $ConfigObject = Get-Content $_ -Raw | ConvertFrom-Json
        
        $DxEntityConfig.Add($_.BaseName,$ConfigObject)
    }

Pop-Location

Export-ModuleMember -Variable DxEntityConfig

#endregion EntityConfig
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
#endregion Functions
;;
Pop-Location 
