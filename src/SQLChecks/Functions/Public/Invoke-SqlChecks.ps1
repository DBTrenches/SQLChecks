Function Invoke-SqlChecks {
    [CmdletBinding(DefaultParameterSetName = "ConfigVariable")]
    Param(
        [Parameter(ParameterSetName = "ConfigVariable", Mandatory = $true, Position = 0)]
        $Config,

        [Parameter(ParameterSetName = "ConfigPath", Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName)]
        [Alias("FullName")]
        [ValidateScript( {
                Test-Path -Path $_ -PathType Leaf
            })]
        [string]
        $ConfigPath,

        [Alias("Tags")]
        [string[]] $Tag,

        [switch]
        $PassThru,

        [Pester.OutputTypes]
        $Show = 'All'
    )
    Begin {
        $path = ($script:MyInvocation.MyCommand.Path | Split-Path) + '\Tests'
    }
    Process {
        if ($PSCmdlet.ParameterSetName -eq "ConfigPath") {
            $Config = Read-SqlChecksConfig -Path $ConfigPath
        }

        if ($Tag) {
            Invoke-Pester -Script @{Path = $path; Parameters = @{config = $Config}} -Tag $Tag -PassThru:$PassThru -Show $Show
        }
        else {
            foreach ($check in Get-SqlChecksFromConfig -Config $Config) {
                Invoke-Pester -Script @{Path = $path; Parameters = @{config = $Config}} -Tag $check -PassThru:$PassThru -Show $Show
            }
        }
    }
}