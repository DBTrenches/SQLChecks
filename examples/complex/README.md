# Complex Example

This folder has an example configuration which demonstrates a SQLChecks deployment that leverages both _templates_ and _environments_.

## Environment

Our sample has three environments, each of which has a different number of nodes:

- QA
  - QASQL01
- PreProd
 - PRESQL01
 - PRESQL02
- Prod
 - PRODSQL01
 - PRODSQL02

There is a single availability group, which only exists in PreProd and Prod, called AG1.

We also have a couple of templates:

- Baseline (All)
- Prod

The idea of a template is that there are some configuration values which we want to apply to all of our servers (Baseline), and some which we want to apply to all production servers.

All of this maps to the following folder structure:

- Environments
  - QA
    - QA.servers.json
    - QASQL01.config.json
  - PreProd
    - PreProd.servers.json
    - PRESQL01.config.json
    - PRESQL02.config.json
    - AG1.config.json
  - Prod
    - Prod.servers.json
    - PRODSQL01.config.json
    - PRODSQL02.config.json
    - AG1.config.json
- Templates
  - Baseline.config.json
  - Prod.config.json

The `.config.json` files are SQLChecks files.  Templates do not contain a `ServerInstance` value, and that must be injected at check-time (see below).

Each environment contains a `.servers.json` file, which lists out the servers in that environment.

> Naming of all of these files is a convention and can be customised.  Mapping of templates to environments is arbitrary and hardcoded in the example below, but you could keep a mapping file or use a convention, e.g. PROD.config.json automatically applies to a PROD environment.

## Example Implementation

We perform three loops - one for regular checks, one for 'all' templates, and one for 'prod' templates.

In a typical deployment where there may not be line of sight to every server (e.g. QA cannot access prod), you would only deploy the environments that the host machine can access.

```powershell
# Regular checks - per-node/AG
foreach($sqlChecksConfig in Get-ChildItem -Path ./Environments -Filter "*.config.json")
{
    $config = Read-SqlChecksConfig -Path $sqlChecksConfig.FullName

    foreach($check in Get-SqlChecksFromConfig -Config $config)
    {
        Write-Output "Checking $check on $($config.ServerInstance)"
        Invoke-SqlChecks -Config $config -Tag $check @invokeSqlChecksParameters
    }
}

# Template checks - all
$allTemplates = @("baseline.config.json")
foreach($template in $allTemplates)
{
  $config = Read-SqlChecksConfig (Get-ChildItem -Path .\Templates -Filter $template -Recurse).FullName
  $servers = @()

  foreach($serverFile in Get-ChildItem -Path .\Environments -Filter "*.servers.json" -Recurse)
  {
    $servers += $serverFile | Get-Content -Raw | ConvertFrom-Json | Select-Object -Expand ServerInstances
  }

  foreach($serverInstance in $servers)
  {
    $config.ServerInstance = $serverInstance
    foreach($check in Get-SqlChecksFromConfig -Config $config)
    {
        Write-Output "Checking $check on $($config.ServerInstance)"
        Invoke-SqlChecks -Config $config -Tag $check @invokeSqlChecksParameters
    }
  }
}

# Template checks - prod
$prodTemplates = @("prod.config.json")
foreach($template in $prodTemplates)
{
  $config = Read-SqlChecksConfig (Get-ChildItem -Path .\Templates -Filter $template -Recurse).FullName

  # Property likely not present, add it
  if($null -eq $config.ServerInstance)
  {
    $config | Add-Member NoteProperty ServerInstance ""
  }

  $servers = @()

  # Note usage of Prod in the Path filter
  foreach($serverFile in Get-ChildItem -Path .\Environments\Prod -Filter "*.servers.json" -Recurse)
  {
    $servers += $serverFile | Get-Content -Raw | ConvertFrom-Json | Select-Object -Expand ServerInstances
  }

  foreach($serverInstance in $servers)
  {
    $config.ServerInstance = $serverInstance
    foreach($check in Get-SqlChecksFromConfig -Config $config)
    {
        Write-Output "Checking $check on $($config.ServerInstance)"
        Invoke-SqlChecks -Config $config -Tag $check @invokeSqlChecksParameters
    }
  }
}
```