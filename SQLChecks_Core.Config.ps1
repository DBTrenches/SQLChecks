
Push-Location $PSScriptRoot

$ConfigFile = Get-Item ./ModuleConfig/SqlChecks.Config.json -ErrorAction SilentlyContinue

if($null -eq $ConfigFile){
    $ModuleConfig = Get-Content ./ModuleConfig/SqlChecks.Config.Example.json | ConvertFrom-Json
    $ModuleConfig.TemplateConfig.PathExpression = './ModuleConfig/SqlChecks.Config.json'
    $ModuleConfig | ConvertTo-Json | Set-Content ./ModuleConfig/SqlChecks.Config.json
    $ConfigFile = Get-Item ./ModuleConfig/SqlChecks.Config.json 
} else {
    $ModuleConfig = Get-Content $ConfigFile -Raw | ConvertFrom-Json
}

$Global:DxEntityConfig = @{}

    Push-Location $ModuleConfig.EntityConfig.PathExpression

        Get-ChildItem . -Recurse -Filter *.json | ForEach-Object {
            $ConfigObject = Get-Content $_ -Raw | ConvertFrom-Json
            
            $RootKey = $_.Directory.Name
            
            if(-not $DxEntityConfig.$RootKey){
                $DxEntityConfig.Add($RootKey,@{})
            }
            $DxEntityConfig.$RootKey.Add($_.BaseName,$ConfigObject)
        }

    Pop-Location

$global:DxDefaults = (Get-Content ./ModuleConfig/SqlChecks.Config.json | ConvertFrom-Json).Defaults

Pop-Location
