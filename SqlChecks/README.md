> :danger: Work in progress!

Intended to hold the root of SQLChecks v2.  Rather than a long-running branch (which may involve a significant number of structural changes to files/folders), starting 'fresh' here.

## Goals

- Work with Pester v5 (see [#21](https://github.com/DBTrenches/SQLChecks/issues/21))
- Be entirely self-contained
- Be compatible with config files authored in v1
- Be compatible with reporting on results from v1 (i.e the update to v2 should be transparent for applications consuming the results)
- Allow the surface area of tests to be extended without changing the module
- Make it as simple as possible to author a test (see [#22](https://github.com/DBTrenches/SQLChecks/issues/22))

## Not Goals

- Be compatible with v1 runners (e.g. wrappers around SQLChecks that iterate over configs may break)
- Have the same public surface area (the list of public functions should be massively reduced)
- Support updates (the lone Set-SpConfig may not have a future in core)

## Notes

I suspect the easiest way to allow SQLChecks to be extended is with `New-PesterContainer`, something like:

```powershell
$extraChecks = @("path\to\SQLChecks.Extensions.tSqlScheduler")
Invoke-SqlChecks -CheckFile $pathToCheckFile -AdditionalTests $extraChecks
```

By default all core checks are in scope, and we can pass in 0 or more folders containing test files.  If the test files are self-contained (all logic within that file/files) there is no need to import any additional modules.  This should also massively speed up development of tests.

## Running Checks

The boilerplate for running checks will be reduced with the migration to v5.  One key difference is it will no longer be required to iterate over checks (see https://github.com/DBTrenches/SQLChecks/issues/21#issuecomment-913199854).

```powershell
# v4
foreach($config in $folderFullOfConfigs) {
  foreach($check in Read-SqlChecksFromFile $config) {
    Invoke-SqlCheckToSomeOutput -Params ...
  }
}

# v4
foreach($config in $folderFullOfConfigs) {
  Invoke-SqlCheckToSomeOutput $config
}
```

Based on this I don't think there is value to be gained in writing primitives to support running, though perhaps a more fully-fledged example could help?

One decision to make is on supporting iteration - how often to ship results.  You could imagine a wrapper function that points at a folder full of configs and iterates over them all.  Ceding control of how often to ship results (consider partial failures after 45 mins of checks) I don't think is the right tradeoff, especially as the amount of extra code is minimal.

The second place that generates a tonne of boilerplate is custom checks.  If the approach with Pester's containers works as expected, that should also vanish.

## Todo

Many things.
