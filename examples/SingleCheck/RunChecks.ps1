#Requires -Modules DBATools, SQLChecks

[string]$data = Get-Content -Path .\localhost.config.json -Raw
$data | ConvertFrom-Json -OutVariable cfg

Invoke-Pester -Script @{Path='.';Parameters= @{configs=@($cfg)}} 