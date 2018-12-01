Function Get-ValueFromCache {
  [cmdletbinding()]
  Param(
    [Parameter(Mandatory = $true)]
    $Key

    , [Parameter(Mandatory = $true)]
    [ScriptBlock]
    $Value
  )

  if (-not (Get-Variable -Name CachedData -Scope Global -ErrorAction SilentlyContinue)) {
    Write-Verbose "Did not find CachedData in the script scope"
    Set-Variable -Name CachedData -Scope Global -Value @{}
  }

  $cache = Get-Variable -Name CachedData -Scope Global
  if (-not $cache.Value.ContainsKey($Key)) {
    Write-Verbose "Did not find $Key in the cache, populating"
    $cachedValue = &$Value
    $cache.Value[$Key] = $cachedValue
  }
  else {
    Write-Verbose "Found $Key in the cache"
    $cachedValue = $cache.Value[$Key]
  }
  
  $cachedValue
}