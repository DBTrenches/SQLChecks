# SQLChecks
[![Build Status](https://img.shields.io/appveyor/ci/taddison/SQLChecks.svg)](https://ci.appveyor.com/project/taddison/sqlchecks)
[![Test Status](https://img.shields.io/appveyor/tests/taddison/SQLChecks.svg)](https://ci.appveyor.com/project/taddison/sqlchecks/build/tests)

Helper functions and tests for SQL Server.

Requires the SqlServer and DBATools modules.

The examples folder contains a few different ways of invoking the scripts - against a single instance (SingleCheck) or against a folder full of instances (FolderCheck).

For more information refer to [the documentation](./docs/Readme.md).

## Example Usage
(From the root)

```powershell
Import-Module .\src\SQLChecks -Force

cd .\examples\SingleCheck
.\RunChecks.ps1
```

## Testing a single item from config
```powershell
Import-Module .\src\SQLChecks -Force

$config = Read-SqlChecksConfig -Path ".\examples\SingleCheck\localhost.config.json"
Test-TraceFlags -ServerInstance $config.ServerInstance -ExpectedFlags $config.TraceFlags
```