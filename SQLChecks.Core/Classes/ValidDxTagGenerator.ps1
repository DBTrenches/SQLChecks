# HT https://vexx32.github.io/2018/11/29/Dynamic-ValidateSet/

using namespace System.Management.Automation

class ValidDxTagGenerator : IValidateSetValuesGenerator {
    [string[]] GetValidValues() {
        $Values = @(
            'SqlAgent.Status'                         # 'AgentIsRunning'
            'SqlAgent.Jobs.Schedules.NoneDisabled'    # 'AgentJobNoDisabledSchedules'
            'SqlAgent.Jobs.AllHaveOneActiveSchedule'  # 'AgentJobOneActiveSchedule'
            'AG.Connectivity'                         # 'AGInstanceConnectivity'
            'AG.PrimaryHealthStatus'                  # 'AGPrimaryHealthStatus'
            'AG.SyncCommitHealthStatus'               # 'AGSyncCommitHealthStatus'
            'AzureDBCertificateAuth'
            'AzureDBCheckDuplicateIndexes'
            'AzureDBMaxDataFileSize'
            'CheckDuplicateIndexes'
            'CheckForIdentityColumnLimit'
            'CheckForOrphanedResumableIndexRebuild'
            'CheckForOversizedIndexes'
            'CheckForPercentageGrowthLogFiles'
            'CheckUnconfiguredSQLAgentAlerts'
            'CustomCheck_LastGoodFullBackup'
            'CustomCheck_LastGoodIntegrityCheck'
            'CustomCheck_LastGoodRestoredBackupCheck'
            'CustomCheck_LastGoodSecondaryReplicaCheckDb'
            'CustomCheck_NonAllowedLogins'
            'CustomCheck_NonDeployedSchedulerTasks'
            'CustomCheck_RunningLogBackups'
            'DatabaseMail'
            'IFIEnabled'
            'LastGoodCheckDb'
            'LockPagesInMemoryEnabled'
            'MaxDataFileSize'
            'MaxTLogAutoGrowthInKB'
            'MustHaveDDLTrigger'
            'NumErrorLogs'
            'ResourceGovernorPools'
            'ResourceGovernorSetting'
            'ServiceBrokerShouldBeEnabled'
            'ShouldCheckForAutoGrowthRisks'
            'SpConfig'
            'SqlAgent.Alerts' # 'SQLAgentAlerts'
            'SqlAgent.Operators' # 'SQLAgentOperators'
            'SQLEndpoints'
            'SQLServicesStartup'
            'StartupXEvents'
            'TempDBConfiguration'
            'TraceFlags'
            'ZeroAutoGrowthFiles'
        )
        return $Values
    }
}
