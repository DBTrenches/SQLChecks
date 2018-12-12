# SQLChecks
[![Build Status](https://img.shields.io/appveyor/ci/taddison/SQLChecks.svg)](https://ci.appveyor.com/project/taddison/sqlchecks)
[![Test Status](https://img.shields.io/appveyor/tests/taddison/SQLChecks.svg)](https://ci.appveyor.com/project/taddison/sqlchecks/build/tests)

Helper functions and tests for SQL Server.

Requires the `SqlServer`, `Pester`, and `OMSIngestionAPI` modules.

The examples folder contains a few different ways of invoking the scripts - against a single instance (SingleCheck) or against a folder full of instances (FolderCheck).

For more information refer to [the documentation](./docs/Readme.md).

## Example Usage
First of all import the module.

```powershell
Import-Module .\src\SQLChecks -Force
```

And then pass a configuration file to `Invoke-SqlChecks`.

```powershell
Invoke-SqlChecks -ConfigPath .\examples\localhost.config.json
```

You can also test a single item based on its tag.

```powershell
Invoke-SqlChecks -ConfigPath .\examples\localhost.config.json -Tag CheckForOversizedIndexes
```

Or loop through a set of configuration files (`Invoke-SqlChecks` accepts paths on the pipeline, as well as objects from `Get-ChildItem`).

```powershell
Get-ChildItem -Filter *.config.json -Path .\examples | Invoke-SqlChecks
```

It is also possible to pass configurations to `Invoke-SqlChecks`.

```powershell
$config = Read-SqlChecksConfig .\examples\localhost.config.json
Invoke-SqlChecks -Config $config
```

You can find some example configuration files in the `examples` folder.

## Database Specific Checks
Some checks target a database (e.g. checking for oversized indexes).  By default these checks will skip:

- Databases that are not ONLINE
- Databases that are secondaries in an availability group

Some checks also exclude system databases by default - for more detail consult the test definitions in the `src/SQLChecks/Tests` folder.

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

## PowerShell Core Support
The `SqlServer` module does not currently expose `Invoke-SqlCmd` in PSCore.  Support for `Invoke-SqlCmd` is on the roadmap, and so Core support for SQLChecks will wait on that.

All other dependencies (Pester, OMSIngestionApi) work on Core as of 6.1.
