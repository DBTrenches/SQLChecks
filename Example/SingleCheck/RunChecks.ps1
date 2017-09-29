#Requires -Modules DBATools
. .\..\..\HelperFunctions\Check-TraceFlags.ps1

[string]$config = Get-Content -Path .\localhost.config.json -Raw

Invoke-Pester -Script @{Path='.';Parameters= @{instanceConfig=$config}} 