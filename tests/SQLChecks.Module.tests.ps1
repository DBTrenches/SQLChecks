Import-Module $PSScriptRoot\..\src\SQLChecks -Force

Describe "Import-Module SQLChecks" {
  It "should export at least one function" {
    @(Get-Command -Module SQLChecks).Count | Should BeGreaterThan 0
  }
}

Describe "Module test Describe tags are unique" {
  $tags = @()

  Get-ChildItem -Filter *.tests.ps1 -Path $PSScriptRoot\..\src\SQLChecks\Tests | Get-Content | ForEach-Object {
      $ast = [Management.Automation.Language.Parser]::ParseInput($_, [ref]$null, [ref]$null)
      $ast.FindAll({
          param($node)
          $node -is [System.Management.Automation.Language.CommandAst] -and
          $node.CommandElements[0].Value -eq "Describe"
      }, $true) | ForEach-Object { 
          $tags += $_.CommandElements[3].Value
      }
  }

  foreach($tag in $tags) {
      It "$tag is a unique tag within the module" {
          ($tags | Where-Object {$_ -eq $tag}).Count | Should Be 1
      }
  }
}

Describe "Public functions that directly support tests" {
    $commands = Get-Command -Module SqlChecks | where-object { 
        $_.Name -notin @("Set-SpConfigValue", "Read-SqlChecksConfig", "Get-SpConfigValue")
    }
    foreach($command in $commands) {
        It "$command should accept a Config parameter" {
            $command.Parameters.Keys -contains "Config" | Should Be $true
        }
    }
}