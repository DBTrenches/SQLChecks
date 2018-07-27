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

## Database Specific Checks
Some checks target a database (e.g. checking for oversized indexes).  By default these checks will skip:

- Databases that are not ONLINE
- Databases that are secondaries in an availability group

Some checks also exclude system databases by default.

## Availability Group Support
A config file can specify that databases for a specific availability group should be checked.  This is set with the `DatabasesToCheck` configuration value and the `AvailabilityGroup` value.

To only run database-specific checks on databases that belong to the `AG1` availability group, your config might look like this:

```json
{
    "ServerInstance": "localhost",
    "DatabasesToCheck": "AGOnly",
    "AvailabilityGroup": "AG1"
    ...
}
```

You can also specify a value of `LocalOnly` for `DatabasesToCheck`, which will cause database-specific checks to skip any database that belongs to an availability group.

If you do not specify a value, then every database (except for default exclusions) is checked.