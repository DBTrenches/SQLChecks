#Requires -Modules DBATools, SQLChecks

$instances = Get-ChildItem -Path .\Instances -Filter *.config.json

foreach($instance in $instances) {
    [string]$configData = Get-Content -Path $instance.PSPath -Raw
    $configData | ConvertFrom-Json -OutVariable +config | Out-Null
    Invoke-SqlChecks -Config $config
}