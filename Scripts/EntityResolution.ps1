Push-Location $PSScriptRoot/..

#region TemplateConfig

$DxTemplateConfig = @{}

Push-Location $ModuleConfig.TemplateConfig.PathExpression

    foreach($file in (Get-ChildItem . -Recurse -Include *.json,*.csv)) {
        $ConfigObject = switch($file.Extension){
            '.json' {Get-Content $file -Raw | ConvertFrom-Json}
            '.csv' {Get-Content $file -Raw | ConvertFrom-Csv}
        }
        
        $GrandParent = $file.Directory.Parent.Name
        $Parent = $file.Directory.Name
        
        if(-not $DxTemplateConfig.$GrandParent){
            $DxTemplateConfig.Add($GrandParent,@{})
        }
        if(-not $DxTemplateConfig.$GrandParent.$Parent){
            $DxTemplateConfig.$GrandParent.Add($Parent,@{})
        }
        $DxTemplateConfig.$GrandParent.$Parent.Add($file.BaseName,$ConfigObject)
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
#region EntityLibrary

$DxEntityLibrary = @{}

Push-Location $ModuleConfig.EntityLibrary.PathExpression

    Get-ChildItem . -Recurse -Include *.json | ForEach-Object {
        $ResolvedDateTimeUtc = @{
            MemberType = 'NoteProperty'
            Name = 'ResolvedDateTimeUtc' 
            Value = [System.DateTime]::UtcNow
        }

        $ConfigObject = Get-Content $_ -Raw | ConvertFrom-Json 

        $EntityName = $_.BaseName
        
        $DxEntityLibrary.Add($EntityName,$ConfigObject)

        $DxEntityLibrary.$EntityName | Add-Member @ResolvedDateTimeUtc
    }

Pop-Location

Export-ModuleMember -Variable DxEntityLibrary

#endregion EntityLibrary
;;

Pop-Location
