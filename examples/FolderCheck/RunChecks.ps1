#Requires -Modules SQLChecks

$instances = Get-ChildItem -Path .\Instances -Filter *.config.json

foreach($instance in $instances) {
    $config = Read-SqlChecksConfig -Path $instance.FullName
    Invoke-SqlChecks -Config $config
}