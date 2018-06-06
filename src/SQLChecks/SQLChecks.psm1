# Gets
. $PSScriptRoot/Functions/Get/Get-NumberOfErrorLogs.ps1
. $PSScriptRoot/Functions/Get/Get-TLogsWithLargeGrowthSize.ps1
. $PSScriptRoot/Functions/Get/Get-DatabaseTriggerStatus.ps1
. $PSScriptRoot/Functions/Get/Get-OversizedIndexes.ps1
. $PSScriptRoot/Functions/Get/Get-TLogWithPercentageGrowth.ps1
. $PSScriptRoot/Functions/Get/Get-DatabaseFilesOverMaxDataFileSpaceUsed.ps1
. $PSScriptRoot/Functions/Get/Get-DbsWithoutGoodCheckDb.ps1
. $PSScriptRoot/Functions/Get/Get-DuplicateIndexes.ps1
. $PSScriptRoot/Functions/Get/Get-FixedSizeFiles.ps1
. $PSScriptRoot/Functions/Get/Get-AutoGrowthRisks.ps1
. $PSScriptRoot/Functions/Get/Get-DatabasesToCheck.ps1
. $PSScriptRoot/Functions/Get/Get-SqlAgentJobsWithDisabledSchedule.ps1
. $PSScriptRoot/Functions/Get/Get-SqlAgentJobsWithNoActiveSchedule.ps1
. $PSScriptRoot/Functions/Get/Get-DefaultDatabaseMailProfile.ps1
. $PSScriptRoot/Functions/Get/Get-SpConfigValue.ps1

# Reads
. $PSScriptRoot/Functions/Read/Read-SqlChecksConfig.ps1

# Tests
. $PSScriptRoot/Functions/Test/Test-TraceFlags.ps1
. $PSScriptRoot/Functions/Test/Test-StartupXEvents.ps1

# Sets
. $PSScriptRoot/Functions/Set/Set-SpConfig.ps1
. $PSScriptRoot/Functions/Set/Set-SpConfigValue.ps1

# Utility
. $PSScriptRoot/Functions/Invoke-SqlChecks.ps1