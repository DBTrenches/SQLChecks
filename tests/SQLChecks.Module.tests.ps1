Import-Module $PSScriptRoot\..\src\SQLChecks -Force

Describe "Import-Module SQLChecks" {
    It "should export at least one function" {
        @(Get-Command -Module SQLChecks).Count | Should BeGreaterThan 0
    }
}

Describe "Describe tags are unique" {
    $tags = @()

    Get-ChildItem -Filter *.tests.ps1 -Path $PSScriptRoot\..\src\SQLChecks\Tests | Get-Content -Raw | ForEach-Object {
        $ast = [Management.Automation.Language.Parser]::ParseInput($_, [ref]$null, [ref]$null)
        $ast.FindAll( {
                param($node)
                $node -is [System.Management.Automation.Language.CommandAst] -and
                $node.CommandElements[0].Value -eq "Describe" -and
                $node.CommandElements[2] -is [System.Management.Automation.Language.CommandParameterAst] -and
                $node.CommandElements[2].ParameterName -eq "Tag"
            }, $true) | ForEach-Object {
            $tags += $_.CommandElements[3].Value
        }
    }

    foreach ($tag in $tags) {
        It "$tag is a unique tag within the module" {
            ($tags | Where-Object {$_ -eq $tag}).Count | Should Be 1
        }
    }
}

Describe "Public functions that directly support tests" {
    $excludedFunctions = @("Set-SpConfigValue", "Read-SqlChecksConfig",
        "Get-SpConfigValue", "Get-DatabasesToCheck", "Get-CachedScriptBlockResult",
        "Get-AGDatabaseReplicaState", "Remove-SQLChecksCache")

    $commands = Get-Command -Module SqlChecks | where-object {
        $_.Name -notin $excludedFunctions
    }
    foreach ($command in $commands) {
        It "$command should accept a Config parameter" {
            $command.Parameters.Keys -contains "Config" | Should Be $true
        }
    }
}

Describe "Every test has a tag" {
    Get-ChildItem -Filter *.tests.ps1 -Path $PSScriptRoot\..\src\SQLChecks\Tests | ForEach-Object {
        $content = Get-Content $_.FullName -Raw
        Context "$_" {
            $ast = [Management.Automation.Language.Parser]::ParseInput($content, [ref]$null, [ref]$null)
            $ast.FindAll( {
                    param($node)
                    $node -is [System.Management.Automation.Language.CommandAst] -and
                    $node.CommandElements[0].Value -eq "Describe"
                }, $true) | ForEach-Object {
                It "$($_.CommandElements[1]) has a tag" {
                    $_.CommandElements[2] -is [System.Management.Automation.Language.CommandParameterAst] -and
                    $_.CommandElements[2].ParameterName -eq "Tag" | Should Be $true
                }
            }
        }
    }
}