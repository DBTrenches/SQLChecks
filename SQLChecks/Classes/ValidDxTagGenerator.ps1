# HT https://vexx32.github.io/2018/11/29/Dynamic-ValidateSet/

using namespace System.Management.Automation

class ValidDxTagGenerator : IValidateSetValuesGenerator {
    [string[]] GetValidValues() {
        $Values = @(
            '_Utility.select1'
            'Databases.DuplicateIndexes'                # 'CheckDuplicateIndexes'
            'Databases.IdentityColumnLimit'             # 'CheckForIdentityColumnLimit'
            'Databases.Files.SpaceUsed'
            'Databases.OversizedIndexes'
            'Management.NumErrorLogs'                   # 'NumErrorLogs'
            'Management.Xevents'
            'Security.SysAdmins'
            'Service.SysConfigurations'                 # 'SpConfig'
            'Service.TempDbConfiguration'               # 'TempDBConfiguration'
            'Service.TraceFlags'                        # 'TraceFlags' 
            'SqlAgent.Alerts'                           # 'SQLAgentAlerts'
            'SqlAgent.JobSchedules.Disabled'            # 'AgentJobNoDisabledSchedules'
            'SqlAgent.JobSchedules.NoneActive'          # 'AgentJobOneActiveSchedule'
            'SqlAgent.Operators'                        # 'SQLAgentOperators'
            'SqlAgent.Status'                           # 'AgentIsRunning'
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
            # 'ZeroAutoGrowthFiles'
        )
        return $Values
    }
}
