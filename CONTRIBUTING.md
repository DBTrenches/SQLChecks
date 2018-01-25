# SQLChecks Contribution Guidelines
- One file per PowerShell function
- Update at least one example config with each new test
- Add documentation for each new test
- Verb selection: Test if logic is being applied, Get if values from the target are being returned
- Locate tests in the appropriate test file (instance, database, etc.)
- Every test must be configurable (either what it tests, or a global on/off option)
- Return objects from get/test functions (rather than writing to the host)
- Don't use aliases (Get-Content vs. gc)