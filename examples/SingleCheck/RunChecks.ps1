#Requires -Modules DBATools, SQLChecks

[string]$data = Get-Content -Path .\localhost.config.json -Raw
$data | ConvertFrom-Json -OutVariable configs | Out-Null

Invoke-SqlChecks -Config $configs