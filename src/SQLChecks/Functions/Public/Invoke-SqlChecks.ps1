Function Invoke-SqlChecks {
    [cmdletbinding()]
    Param(
        [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true)]
        [Alias("Configs")]
        $Config,

        [Alias("Tags")]
        [string[]] $Tag,

        [switch]
        $PassThru
    )

    $path = ($script:MyInvocation.MyCommand.Path | Split-Path) + '\Tests'

    if($Tag) {
        Invoke-Pester -Script @{Path=$path;Parameters= @{config=$Config}} -Tag $Tag -PassThru:$PassThru
    } else {
        foreach($check in Get-SqlChecksFromConfig -Config $Config) {
        Invoke-Pester -Script @{Path=$path;Parameters= @{config=$Config}} -Tag $check -PassThru:$PassThru
        }
    }
}