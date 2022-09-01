
function Invoke-DxChecks {
    [CmdletBinding()]
    Param ()

    Push-Location $PSScriptRoot/../..

    Invoke-Pester ./Checks

    Pop-Location
}