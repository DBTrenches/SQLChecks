#Requires -Modules DBATools, SQLChecks

$instances = Get-ChildItem -Path .\Instances -Filter *.config.json
$configs = @()

foreach($instance in $instances) {
    [string]$configData = Get-Content -Path $instance.PSPath -Raw
    $configData | ConvertFrom-Json -OutVariable +configs
}
Invoke-Pester -Script @{Path='.';Parameters= @{configs=$configs}}
