# SQLChecks Contribution Guidelines

Contributions are welcome!  If there isn't an existing issue you're tackling, please raise an issue before submitting a PR.

## Before submitting a PR
- Run `Invoke-Pester` from the `.\tests` folder

## Contributing a new test
- Add the test to the relevant `tests.ps1` file (Instance, Agent, etc.)
- Add the supporting functions in the appropriate folder (public/private)
- Add an example of the test configuration in the `examples` folder
- Add the documentation to the `docs` folder
- Each test is uniquely identified by its tag, which also serves as the configuration name
- Most test functions should accept either Config or a set of parameters.  For an example see [Test-TraceFlags.ps1](/src/SQLChecks/Functions/Public/Test-TraceFlags.ps1)

## General guidelines
- One file per PowerShell function
- Return objects from get/test functions (rather than writing to the host)
- Don't use aliases (use `Get-Content` instead of `gc`)