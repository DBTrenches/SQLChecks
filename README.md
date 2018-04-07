# SQLChecks
Helper functions and tests for SQL Server.

Requires the DBATools module.

The examples folder contains a few different ways of invoking the scripts - against a single instance (SingleCheck) or against a folder full of instances (FolderCheck).

For more information refer to [the documentation](./docs/Readme.md).

## Example Usage
(From the root)

```powershell
#Requires -Modules DBATools, SQLChecks

cd .\examples\SingleCheck
.\RunChecks.ps1
```

## Testing a single item from config
```powershell
#Requires -Modules DBATools, SQLChecks

Get-Content -Path ".\examples\SingleCheck\localhost.config.json" -Raw | ConvertFrom-Json -OutVariable cfg | Out-Null
Test-TraceFlags -ServerInstance $cfg.ServerInstance -ExpectedFlags $cfg.TraceFlags
```

## Building a report based on checks against all configs in a folder
```powershell
#Requires -Modules DBATools, SQLChecks, Format-Pester, PScribo

$instances = Get-ChildItem -Path .\examples\FolderCheck\Instances -Filter *.config.json
$configs = @()

foreach($instance in $instances) {
    [string]$configData = Get-Content -Path $instance.PSPath -Raw
    $configData | ConvertFrom-Json -OutVariable +configs
}
Invoke-SqlChecks -Config $configs -PassThru | Format-Pester -Format HTML -Path .
```