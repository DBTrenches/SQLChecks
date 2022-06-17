$functionFileCollection = Get-ChildItem -Recurse -Filter *.ps1 -Path $PSScriptRoot/src/SQLChecks/Functions

foreach($functionFile in $functionFileCollection) {
    . $functionFile.FullName
}