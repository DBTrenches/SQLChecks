@{
    RootModule        = 'SQLChecks.psm1'
    ModuleVersion     = '1.3.1'
    GUID              = '998f41a0-c4b4-4ec5-9e11-cb807d98d969'
    Author            = 'Timothy Addison'
    Copyright         = '(c) 2017-2022 Timothy Addison & DBTrenches. All rights reserved.'
    RequiredModules   = @(
	'Az.Accounts'
        'SqlServer'
        # anything in Pester v4, not sure if there's a more elegant way to express this
        @{
            ModuleName     = 'Pester'
            ModuleVersion  = '4.0'
            MaximumVersion = '4.999'
            Guid           = 'a699dea5-2c73-4616-a270-1f7abb777e71'
        }
    )
    FunctionsToExport = '*'
    CmdletsToExport   = '*'
    VariablesToExport = '*'
    AliasesToExport   = '*'
}