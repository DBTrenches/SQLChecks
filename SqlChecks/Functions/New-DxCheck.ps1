function New-DxCheck {
<#
.SYNOPSIS
    Creates placeholder components needed to initialise a new SqlCheck

.DESCRIPTION
    1. Given an input $Tag that does not already exist in the Tag Collection
    2. Add that Tag to the Collection (defined in the DxTagGenerator class file)
    3. Add a (blank) SqlLibrary file for the Tag and open it for editting
    4. Add a stub test snippet to the appropriate .tests.ps1 file
    5. TODO: handle for adding config

#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Tag
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
    Invoke-Item "SqlLibrary/$($Tag).sql" 

    # 4. add a stub test and open for editting
    $QueryDomain = ($Tag -split '\.')[0]
    $EndOfTag = $Tag -replace "$QueryDomain."
    $TestFile = Get-ChildItem "Tests/${QueryDomain}.tests.ps1"
    if(-not $TestFile){
        $header = (Get-Content Tests/SqlAgent.tests.ps1)[0..29]
        $TestFile = New-Item -ItemType File -Name "Tests/${QueryDomain}.tests.ps1" -Value $header
    }
    $footer = @"

Describe "${Tag} on '`$ConnectionString' " -Tag ${Tag} {
    BeforeDiscovery {
        `$Splat = @{
            ServerData = Get-DxState -Tag ${Tag} @Connect 
            ConfigData = `$DxEntity.${Tag} 
        }
        `$Collection = Join-DxConfigAndState @Splat
    }
    It "${EndOfTag}: '<_.Name>' " -ForEach `$Collection {
        `$_.ExistsOnServer | Should -BeTrue
        `$_.ExistsInConfig | Should -BeTrue
    }
}
"@
    Add-Content -Path $TestFile -Value $footer
    Invoke-Item $TestFile

    # 5. TODO: handle for adding config

    Pop-Location
}
