Function Get-CachedScriptBlockResult {
    [cmdletbinding()]
    Param(
        [Parameter(Mandatory = $true)]
        $Key,

        [Parameter(Mandatory = $true)]
        [ScriptBlock]
        $ScriptBlock
    )

    $CACHE_VARIABLE_NAME = "SQLChecks_Cache"

    if (-not (Get-Variable -Name $CACHE_VARIABLE_NAME -Scope Global -ErrorAction SilentlyContinue)) {
        Write-Verbose "Did not find CachedData in the global scope"
        Set-Variable -Name $CACHE_VARIABLE_NAME -Scope Global -Value @{}
    }

    $cache = Get-Variable -Name $CACHE_VARIABLE_NAME -Scope Global
    if (-not $cache.Value.ContainsKey($Key)) {
        Write-Verbose "Did not find $Key in the cache, populating"
        $cachedValue = &$ScriptBlock
        $cache.Value[$Key] = $cachedValue
    }
    else {
        Write-Verbose "Found $Key in the cache"
        $cachedValue = $cache.Value[$Key]
    }

    $cachedValue
}