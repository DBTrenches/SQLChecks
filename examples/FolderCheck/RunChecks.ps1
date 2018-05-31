#Requires -Modules DBATools, SQLChecks

$instances = Get-ChildItem -Path .\Instances -Filter *.config.json

foreach($instance in $instances) {
    $config = Read-SqlChecksConfig -Path $instance.PSPath
    Invoke-SqlChecks -Config $config
}