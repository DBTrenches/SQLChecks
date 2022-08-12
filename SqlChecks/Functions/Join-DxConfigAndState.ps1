function Join-DxConfigAndState {
<#
.SYNOPSIS
    SQL `OUTER JOIN` data from `$DxEntityLibrary` and `Get-DxState` for use in a Pester v5 data-driven test

.DESCRIPTION
    Pester v5 needs the data object for a data-driven test to be completely resolved in the `BeforeDiscovery` phase. 
    This means (I think...) that both Config and Server data need to be sensibly merged into a single [PsObject[]]
    in order to pass it downstream out of the `BeforeDiscover` block to an actually test. This logic is reasonably 
    verbose and arcane, but consistent enough that it can be packaged into this function. Using this function rather 
    than in-line scripting saves about 25 lines per test. 

.PARAMETER KeyName
    Both Config data (from $DxEntityLibrary) and Server data (from Get-DxState) need to have a common attribute to JOIN on 
    even if there is a one-row or zero-row set returned. By default this will be `Name` but can be manually set. Keys that
    are present in Config only will have a $false value for the .ExistsOnServer attribute. Likewise keys that are found in
    Server data but are not in Config will have a $false value for the .ExistsInConfig attribute. Typically a $false value
    for either of these attributes will trigger a failed test.

.PARAMETER ServerData
    This Data should be retrieved by the Get-DxState function from a Server target. 

.PARAMETER ConfigData
    This data should already exist in memory in the $DxEntityLibrary module variable.
#>
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $KeyName = 'Name',

        [Parameter(Mandatory)]
        [AllowNull()]
        [object]
        $ServerData,

        [Parameter(Mandatory)]
        [AllowNull()]
        [object]
        $ConfigData
    )

    if($ServerData){
        if($KeyName -NotIn ($ServerData | Get-Member | Where-Object MemberType -eq 'NoteProperty').Name){
            Write-Error "Specific Key '$KeyName' is not present in supplied `$ServerData attributes. "
        }
    }

    $ConfigHasProperties = if($ConfigData){
        [bool]($ConfigData | Get-Member | Where-Object MemberType -eq 'NoteProperty')
    } else {
        $false
    }
    
    if($ConfigHasProperties){
        if($KeyName -NotIn ($ConfigData | Get-Member | Where-Object MemberType -eq 'NoteProperty').Name){
            Write-Error "Specific Key '$KeyName' is not present in supplied `$ConfigData attributes. "
        }
    }

    $ReturnCollection = @()
    
    $ConfigData | ForEach-Object {
        $ObjectKey = if($ConfigHasProperties){$_.$KeyName}else{$_}
        $ServerObject = $ServerData | Where-Object { $_.$KeyName -eq $ObjectKey }

        if($ServerObject){
            $ServerObject = $ServerObject | Select-Object -ExcludeProperty $KeyName
            $ServerObjectExists = $true
        } else {
            $ServerObject = @{}
            $ServerObjectExists = $false
        }

        $ReturnCollection += @{
            Name = $ObjectKey
            ExistsInConfig = [bool]$_
            ExistsOnServer = $ServerObjectExists 
            Config = $_ | Select-Object -ExcludeProperty $KeyName
            Server = $ServerObject
        }
    }
    
    $ServerData | Where-Object { $_.$KeyName -NotIn $ReturnCollection.Name } | ForEach-Object {
        $ReturnCollection += @{
            Name = $_.$KeyName
            ExistsInConfig = $false
            ExistsOnServer = $true
            Config = @{} 
            Server = $_ | Select-Object -ExcludeProperty $KeyName
        }
    }

    # Null object (false/false) returned when no value present in config
    # Discard in presence of valid server state
    if($ReturnCollection.Count -gt 1){
        $ReturnCollection = $ReturnCollection | Where-Object {$true -in ($_.ExistsOnServer,$_.ExistsInConfig)}
    } 

    $ReturnCollection 
}
