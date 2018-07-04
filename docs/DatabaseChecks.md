# Database level checks

## Max transaction log fixed growth
```json
"MaxTLogAutoGrowthInKB": 999000
```

Reports on any database which has a fixed growth larger than the config value.

As the log is zeroed out before use it can be a time consuming operation.  When the log is full and an auto-grow is requested all no writes can complete until the grow is completed, and so capping the size of the growth to a value less than 1GB is suggested.

## Transaction log with percentage growth
```json
"CheckForPercentageGrowthLogFiles": {}
```

Reports on any database log with a percentage growth configured.

If the config value is set to false the check will be skipped.

## Required DDL trigger
```json
"MustHaveDDLTrigger": {
    "TriggerName": "TR_LogDDLChanges",
    "ExcludedDatabases": ["ExcludedDatabase1"]
  }
```

Reports on any database which does not contain the specified DDL trigger.  Excludes system databases.

If for example you had a trigger which logged all DDL changes, you might mandate its usage in some of your environments and check for compliance with this test.


## Datafile Size Maximum
```json
"MaxDataFileSize":{
    "Check":true
    ,"SpaceUsedPercent": 90
    ,"WhitelistFiles": ["MyVLDB.ReadOnly_FG1","MyVLDB.ReadOnly_FG2"]
}
```

Polls for files above a certain percentage of fullness. This can help alert you if an autogrow is about to occur. You can opt of this check for on a per-file basis. 

## Oversized indexes
```json
"CheckForOversizedIndexes": {
    "ExcludedDatabases": ["tempdb"]
}
```

Reports on any database which has oversized indexes - potential key size larger than 1700 bytes for a nonclustered index, or 900 bytes for a clustered index. (These values are for SQL 2016+).

## Fixed-Size Files  
```json
"ZeroAutoGrowthWhitelistFiles":{
        "Whitelist": [
                "AdventureWorks2016CTP3_mod"
                ,"templog"
        ]
}
```

Reports files that are not set to auto-grow. You can whitelist fixed size files by adding the name to the config array, or leave the whitelist empty to check every file.

## Auto-growth & at-risk Filegroups
```json
"ShouldCheckForAutoGrowthRisks": {}
```
Filegroups that are permitted to auto-grow should have enough space to do so. `Get-AutoGrowthRisks` reports filegroups that may run out of space and fail to complete the next autogrowth. No whitelist configuration is provided for this check. Set growth to `0` if you wish to disallow further growth actions.

## Last good CheckDB
```json
"LastGoodCheckDb": {
        "MaxDaysSinceLastGoodCheckDB": 7,
        "ExcludedDatabases": [ "tempdb" ]
    }
```
This checks the last good CheckDB date for each databases, based on the threshold provided.  Databases in the whitelist are ignored.

## Duplicate index checks
```json
"CheckDuplicateIndexes": {
        "ExcludeDatabase": [ "msdb", "master", "tempdb", "model" ]
    }
```
This checks for any indexes with duplicate definitions.  You can optionally exclude one or more databases from the check.
