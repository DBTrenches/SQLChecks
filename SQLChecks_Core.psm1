Push-Location $PSScriptRoot

$functionFileCollection = Get-ChildItem -Recurse -Filter *.ps1 -Path ./SQLChecks.Core/Functions

foreach($functionFile in $functionFileCollection) {
    . $functionFile.FullName
}

Pop-Location 
