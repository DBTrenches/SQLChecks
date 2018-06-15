# SQLChecks
Helper functions and tests for SQL Server.

Requires the SqlServer and DBATools modules.

The examples folder contains a few different ways of invoking the scripts - against a single instance (SingleCheck) or against a folder full of instances (FolderCheck).

For more information refer to [the documentation](./docs/Readme.md).

## Example Usage
(From the root)

```powershell
#Requires -Modules SQLChecks

cd .\examples\SingleCheck
.\RunChecks.ps1
```

## Testing a single item from config
```powershell
#Requires -Modules SQLChecks

$config = Read-SqlChecksConfig -Path ".\examples\SingleCheck\localhost.config.json"
Test-TraceFlags -ServerInstance $config.ServerInstance -ExpectedFlags $config.TraceFlags
```