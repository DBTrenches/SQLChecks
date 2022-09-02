Function Invoke-DxChecks {
    [CmdletBinding()]
    Param (
        [switch]$PassThru,

        [Pester.OutputTypes]
        [Alias('Show')]
        $Output = 'All'
    )

    Push-Location $PSScriptRoot/../..

    Invoke-Pester ./Checks -PassThru:$PassThru -Output $Output

    Pop-Location
}
