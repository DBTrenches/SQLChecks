Function Invoke-SqlChecks {
    [cmdletbinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [Alias("Configs")]
        $Config,

        [Alias("Tags")]
        [string[]] $Tag,

        [switch]
        $PassThru
    )

    $path = ($script:MyInvocation.MyCommand.Path | Split-Path) + '\Tests'
    Invoke-Pester -Script @{Path=$path;Parameters= @{configs=$Config}} -Tag $Tag -PassThru:$PassThru
}