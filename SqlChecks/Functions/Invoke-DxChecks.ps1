Function Invoke-DxChecks {
    [CmdletBinding()]
    Param (
        [switch]$PassThru,

        [Pester.OutputTypes]
        $Show = 'All'
    )

    Push-Location $PSScriptRoot/../..

    Invoke-Pester ./Checks -PassThru:$PassThru -Show $Show

    Pop-Location
}
