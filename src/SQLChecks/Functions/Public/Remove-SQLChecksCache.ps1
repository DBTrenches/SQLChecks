Function Remove-SQLChecksCache {
    [cmdletbinding()]
    Param()

    $CACHE_VARIABLE_NAME = "SQLChecks_Cache"
    Set-Variable -Name $CACHE_VARIABLE_NAME -Scope Global -Value @{}
}