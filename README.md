# SQLChecks
[![Build Status](https://img.shields.io/appveyor/ci/taddison/SQLChecks.svg)](https://ci.appveyor.com/project/taddison/sqlchecks)
[![Test Status](https://img.shields.io/appveyor/tests/taddison/SQLChecks.svg)](https://ci.appveyor.com/project/taddison/sqlchecks/build/tests)

**AS AN** _admin in charge of server_ `$Config`
**I WOULD LIKE** _to query the current_ `$State` _of the server_
**SO THAT** _I can compare the_ `$State` _to the_ `$Config`
**AND** _assert that they are the same_

Helper queries and configuration-vs-state tests for SQL Server.

Requires [`dbatools`](https://dbatools.io/) and [`Pester` v5](https://pester.dev/docs/migrations/breaking-changes-in-v5).

<!-- For more information refer to [the documentation](./docs/Readme.md). -->

## Setup

TODO: Explain setup

## Example Usage

Import the module and run tests without arguments to test the default entity. 

```powershell
Import-Module .\SqlChecks.psd1 -Force
Invoke-Pester .\SqlChecks\Tests -Output Detailed
```

You can also test a single item based on its tag.

```powershell
Invoke-Pester .\SqlChecks\Tests\SqlAgent* -Tag SqlAgent.Alerts -Output Detailed
```

> Tip: if you add the command `$PSDefaultParameterValues.'Invoke-Pester:Output' = 'Detailed'` to your `$PROFILE`, you will get `-Output Detailed` every time without having to type it. 

<!-- You can find some example configuration files in the `examples` folder. -->
