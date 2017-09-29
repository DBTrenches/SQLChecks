#Requires -Modules DBATools, SQLChecks

[string]$config = Get-Content -Path .\localhost.config.json -Raw

Invoke-Pester -Script @{Path='.';Parameters= @{instanceConfig=$config}} 