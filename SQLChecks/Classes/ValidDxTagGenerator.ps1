# HT https://vexx32.github.io/2018/11/29/Dynamic-ValidateSet/

using namespace System.Management.Automation

class ValidDxTagGenerator : IValidateSetValuesGenerator {
    [string[]] GetValidValues() {
        $Values = @(
            'Management.NumErrorLogs'                   # 'NumErrorLogs'
            'Service.SysConfigurations'                 # 'SpConfig'
            'Service.TraceFlags'                        # 'TraceFlags' 
            'SqlAgent.Alerts'                           # 'SQLAgentAlerts'
            'SqlAgent.JobSchedules.Disabled'            # 'AgentJobNoDisabledSchedules'
            'SqlAgent.JobSchedules.NoneActive'          # 'AgentJobOneActiveSchedule'
            'SqlAgent.Operators'                        # 'SQLAgentOperators'
            'SqlAgent.Status'                           # 'AgentIsRunning'
            # 'CheckDuplicateIndexes'
            # 'CheckForIdentityColumnLimit'
            # 'CheckUnconfiguredSQLAgentAlerts'
            # 'AG.Connectivity'                         # 'AGInstanceConnectivity'
            # 'AG.PrimaryHealthStatus'                  # 'AGPrimaryHealthStatus'
            # 'AG.SyncCommitHealthStatus'               # 'AGSyncCommitHealthStatus'
            # 'AzureDBCertificateAuth'
            # 'AzureDBCheckDuplicateIndexes'
            # 'AzureDBMaxDataFileSize'
            # 'CheckForOrphanedResumableIndexRebuild'
            # 'CheckForOversizedIndexes'
            # 'CheckForPercentageGrowthLogFiles'
            # 'CustomCheck_LastGoodFullBackup'
            # 'CustomCheck_LastGoodIntegrityCheck'
            # 'CustomCheck_LastGoodRestoredBackupCheck'
            # 'CustomCheck_LastGoodSecondaryReplicaCheckDb'
            # 'CustomCheck_NonAllowedLogins'
            # 'CustomCheck_NonDeployedSchedulerTasks'
            # 'CustomCheck_RunningLogBackups'
            # 'DatabaseMail'
            # 'IFIEnabled'
            # 'LastGoodCheckDb'
            # 'LockPagesInMemoryEnabled'
            # 'MaxDataFileSize'
            # 'MaxTLogAutoGrowthInKB'
            # 'MustHaveDDLTrigger'
            # 'ResourceGovernorPools'
            # 'ResourceGovernorSetting'
            # 'ServiceBrokerShouldBeEnabled'
            # 'ShouldCheckForAutoGrowthRisks'
            # 'SQLEndpoints'
            # 'SQLServicesStartup'
            # 'StartupXEvents'
            # 'TempDBConfiguration'
            # 'ZeroAutoGrowthFiles'
        )
        return $Values
    }
}
