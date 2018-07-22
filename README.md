# SQLChecks
[![Build Status](https://img.shields.io/appveyor/ci/taddison/SQLChecks.svg)](https://ci.appveyor.com/project/taddison/sqlchecks)
[![Test Status](https://img.shields.io/appveyor/tests/taddison/SQLChecks.svg)](https://ci.appveyor.com/project/taddison/sqlchecks/build/tests)

Helper functions and tests for SQL Server.

Requires the `SqlServer` module.

The examples folder contains a few different ways of invoking the scripts - against a single instance (SingleCheck) or against a folder full of instances (FolderCheck).

For more information refer to [the documentation](./docs/Readme.md).

## Example Usage
First of all import the module

```powershell
Import-Module .\src\SQLChecks -Force
```

The preferred way to leverage SQLChecks is to loop through a server configuration and test every specified check.

```powershell
$config = Read-SqlChecksConfig -Path ".\examples\SingleCheck\localhost.config.json"

foreach($check in (Get-SqlChecksFromConfig $config)) {
    Invoke-SqlChecks -Config $config -Tag $check
}
```

You can also test a single item based on its tag.

```powershell
$config = Read-SqlChecksConfig -Path ".\examples\SingleCheck\localhost.config.json"
Invoke-SqlChecks -Config $config -Tag CheckForOversizedIndexes
```

You can find some example invocations and configuration files in the `examples` folder.