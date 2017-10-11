#Requires -Modules DBATools, SQLChecks

[string]$data = Get-Content -Path .\localhost.config.json -Raw
$data | ConvertFrom-Json -OutVariable configs

Invoke-Pester -Script @{Path='..\..\tests';Parameters= @{configs=$configs}} -show Failed