# Database level checks

In all cases if the config value is not present the test will be skipped.

## Max transaction log fixed growth
Reports on any database which has a fixed growth larger than the config value.

As the log is zeroed out before use it can be a time consuming operation.  When the log is full and an auto-grow is requested all no writes can complete until the grow is completed, and so capping the size of the growth to a value less than 1GB is suggested.

```json
"MaxTLogAutoGrowthInKB": 999000
``` 

## Transaction log with percentage growth
Reports on any database log with a percentage growth configured.

If the config value is set to false the check will be skipped.

```json
"CheckForPercentageGrowthLogFiles": true
```

## Required DDL trigger
Reports on any database which does not contain the specified DDL trigger.  Excludes system databases and any databases with a memory optimised filegroup.

If you had a trigger which logged all DDL changes, you might mandate its usage in some of your environments and check for compliance with this test.

```json
"MustHaveDDLTrigger": "TR_LogDDLChanges"
``` 

## Oversided indexes
Reports on any database which has oversized indexes (potential key size larger than 1700 bytes).

If the config value is set to false the check will be skipped.

```json
"CheckForOversizedIndexes": true
```

## Fixed-Size Files  
Reports files that are not set to auto-grow. You can whitelist fixed size files by adding the name to the config array, or leave the whitelist empty to check every file.

```json
"ZeroAutoGrowthWhitelistFiles":{
        "Check": true
        ,"Whitelist": [
                "AdventureWorks2016CTP3_mod"
                ,"templog"
        ]
}
```

## Auto-growth & at-risk Filegroups
```json
"ShouldCheckForAutoGrowthRisks": true
```
Filegroups that are permitted to auto-grow should have enough space to do so. `Get-AutoGrowthRisks` reports filegroups that may run out of space and fail to complete the next autogrowth. No whitelist configuration is provided for this check. Set growth to `0` if you wish to disallow further growth actions.   

## Duplicate index checks
```json
"CheckDuplicateIndexes": {
        "Check": true,
        "ExcludeDatabase": [ "msdb", "master", "tempdb", "model" ]
    }
```
This checks for any indexes with duplicate definitions.  You can optionally exclude one or more databases from the check.