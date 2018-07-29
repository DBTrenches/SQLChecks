# SQLChecks Examples

SQLChecks requires at least one configuration file to run the core command `Invoke-SqlChecks`.  The simplest way to run SQLChecks is by passing a single config file:

```powershell
$config = Read-SqlChecksConfig -Path .\localhost.config.json
Invoke-SqlChecks -Config $config
```

When the `Tag` parameter isn't specified, `Invoke-SqlChecks` will run a check for every configuration value found in the config.  If no configuration values are found, then no checks are run.

To test multiple configuration files you can loop through the files and call `Invoke-SqlChecks` on them all.

```powershell
$files = Get-ChildItem -Path . -Filter *.config.json

foreach($file in $files) {
    $config = Read-SqlChecksConfig -Path $file.FullName
    Invoke-SqlChecks -Config $config
}
```