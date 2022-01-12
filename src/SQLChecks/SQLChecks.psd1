@{
    RootModule        = 'SQLChecks.psm1'
    ModuleVersion     = '1.2.1'
    GUID              = '998f41a0-c4b4-4ec5-9e11-cb807d98d969'
    Author            = 'Timothy Addison'
    Copyright         = '(c) 2018 Timothy Addison All rights reserved.'
    RequiredModules   = @(
        'SqlServer',
        'Pester',
        'OMSIngestionAPI'
    )
    FunctionsToExport = '*'
    CmdletsToExport   = '*'
    VariablesToExport = '*'
    AliasesToExport   = '*'
}