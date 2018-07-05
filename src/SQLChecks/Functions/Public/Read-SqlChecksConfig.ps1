Function Read-SqlChecksConfig {
    [cmdletbinding()]
    Param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [System.IO.FileInfo]
        $Path
    )

    Get-Content -Path $Path -Raw | ConvertFrom-Json
}