
Push-Location $PSScriptRoot

. ./SqlChecks.Core/Classes/ValidDxTagGenerator.ps1

$SqlLibraryFileCollection = Get-ChildItem -Recurse -Filter *.sql -Path ./SQLChecks.Core/SqlLibrary

$global:DxQueryCollection = @{}

foreach($SqlLibraryFile in $SqlLibraryFileCollection){
    $TagName = $SqlLibraryFile.BaseName
    $QueryText = Get-Content $SqlLibraryFile.FullName -Raw
    $DxQueryCollection.Add($TagName,@{QueryText=$QueryText})
}

Pop-Location
