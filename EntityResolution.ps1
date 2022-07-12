Push-Location $PSScriptRoot

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

Pop-Location
