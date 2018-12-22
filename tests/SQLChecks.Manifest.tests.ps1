$manifestLocation = "$PSScriptRoot\..\src\SQLChecks\SQLChecks.psd1"

Describe "SQLChecks Manifest" {
    $manifest = $null

    It "loads correctly" {
        {
            $Script:manifest = Test-ModuleManifest -Path $manifestLocation -ErrorAction Stop
        } | Should Not Throw
    }
}