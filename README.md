# SQLChecks
Helper functions and tests for SQL Server.

Requires the DBATools module.

The examples folder contains a few different ways of invoking the scripts - against a single instance (SingleCheck) or against a folder full of instances (FolderCheck).

## Example Usage
(From the root)

```powershell
Import-Module DBATools
Import-Module .\src\SQLChecks

cd .\examples\SingleCheck
.\RunChecks.ps1
```

## Testing a single item from config
```powershell
Import-Module DBATools
Import-Module .\src\SQLChecks

Get-Content -Path ".\examples\SingleCheck\localhost.config.json" -Raw | ConvertFrom-Json -OutVariable cfg | Out-Null
Test-TraceFlags -ServerInstance $cfg.ServerInstance -ExpectedFlags $cfg.TraceFlags
```