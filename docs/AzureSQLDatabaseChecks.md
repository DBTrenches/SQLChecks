# Azure SQL DB Database level checks

## Datafile Size Maximum
```json
"AzureDBMaxDataFileSize":{
    "Check":true
    ,"CalculateUsingMaxSize": 1
    ,"SpaceUsedPercent": 90
    ,"WhitelistFiles": ["MyVLDB.ReadOnly_FG1","MyVLDB.ReadOnly_FG2"]
}
```

Polls for files above a certain percentage of fullness. This can help alert you if an autogrow is about to occur. You can opt of this check for on a per-file basis.  Set `"CalculateUsingMaxSize": 1` if you want to check space based on file max size instead of current size (default). 

## Duplicate index checks
```json
"AzureDBCheckDuplicateIndexes": {
        "ExcludeDatabase": [ "msdb", "master", "tempdb", "model" ]
    }
```
This checks for any indexes with duplicate definitions.  You can optionally exclude one or more databases from the check. 
