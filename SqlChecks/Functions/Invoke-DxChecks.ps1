Function Invoke-DxChecks {
<#
.PARAMETER Output
    Map to https://github.com/pester/Pester/blob/13fb4a2686668d455b8cb9922760e9b651ec6b3f/src/Main.ps1#L570
#>
    [CmdletBinding()]
    Param (
        [switch]$PassThru,

        [ValidateSet("Diagnostic", "Detailed", "Normal", "Minimal", "None")]
        [Alias('Show')]
        [String] 
        $Output = "Normal"
    )

    Push-Location $PSScriptRoot/../..

    Invoke-Pester ./Checks -PassThru:$PassThru -Output $Output

    Pop-Location
}
