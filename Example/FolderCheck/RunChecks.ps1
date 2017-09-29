#Requires -Modules DBATools
. .\..\..\HelperFunctions\Check-TraceFlags.ps1

$instances = Get-ChildItem -Path .\Instances -Filter *.config.json

foreach($instance in $instances) {
    [string]$config = Get-Content -Path $instance.PSPath -Raw
    Invoke-Pester -Script @{Path='.';Parameters= @{instanceConfig=$config}}
}
