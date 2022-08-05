@{
    # Required for data-driven tests. `BeforeDiscovery` and `It` are
    # separate child processes so PSSA cannot account that vars defined
    # in `BeforeDiscovery` are used at test-time. Consider enabling this 
    # rule periodically to check for bona-fide violations in functions 
    # or other non-`*.Tests.ps1` powershells script in this repo
    ExcludeRules = @(
        'PSUseDeclaredVarsMoreThanAssignments'
    )
}