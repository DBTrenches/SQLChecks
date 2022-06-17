
Push-Location $PSScriptRoot

$ClassFileCollection = Get-ChildItem -Recurse -Filter *.ps1 -Path ./SQLChecks.Core/Classes

foreach($ClassFile in $ClassFileCollection) {
    . $ClassFile.FullName
}

$SqlLibraryFileCollection = Get-ChildItem -Recurse -Filter *.sql -Path ./SQLChecks.Core/SqlLibrary

$global:DxQueryCollection = @{}

foreach($SqlLibraryFile in $SqlLibraryFileCollection){
    $TagName = $SqlLibraryFile.BaseName
    $QueryText = Get-Content $SqlLibraryFile.FullName -Raw
    $DxQueryCollection.Add($TagName,@{QueryText=$QueryText})
}

Pop-Location
