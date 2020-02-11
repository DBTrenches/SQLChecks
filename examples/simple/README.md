# Simple Examples

A few example configurations, ranging from `minimal` which is valid but performs no checks, to `localhost` and `127.0.0.1` which perform a few more.

## Usage

The below script executes all config files discovered in the folder.

```powershell
foreach($sqlChecksConfig in Get-ChildItem -Filter "*.config.json" -Recurse)
{
    $config = Read-SqlChecksConfig -Path $sqlChecksConfig.FullName

    foreach($check in Get-SqlChecksFromConfig -Config $config)
    {
        Write-Output "Checking $check on $($config.ServerInstance)"
        Invoke-SqlChecks -Config $config -Tag $check @invokeSqlChecksParameters
    }
}
```
