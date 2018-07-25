#Requires -Modules SQLChecks

$configs = Read-SqlChecksConfig -Path .\localhost.config.json

Invoke-SqlChecks -Config $configs