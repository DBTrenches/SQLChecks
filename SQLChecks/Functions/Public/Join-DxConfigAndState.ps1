function Join-DxConfigAndState {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $KeyName = 'Name',

        [Parameter(Mandatory)]
        [object]
        $ServerData,

        [Parameter(Mandatory)]
        [object]
        $ConfigData
    )

    if($KeyName -NotIn ($ServerData | Get-Member | Where-Object MemberType -eq 'NoteProperty').Name){
        Write-Error "Specific Key '$KeyName' is not present in supplied `$ServerData attributes. "
    }

    if($KeyName -NotIn ($ConfigData | Get-Member | Where-Object MemberType -eq 'NoteProperty').Name){
        Write-Error "Specific Key '$KeyName' is not present in supplied `$ConfigData attributes. "
    }

    $ReturnCollection = $ConfigData | ForEach-Object {
        $ObjectKey = $_.$KeyName
        $ServerObject = $ServerData | Where-Object { $_.$KeyName -eq $ObjectKey }
        if($ServerObject){
            $ServerObject = $ServerObject | Select-Object -ExcludeProperty $KeyName
            $ServerObjectExists = $true
        } else {
            $ServerObject = @{}
            $ServerObjectExists = $false
        }
        @{
            Name = $ObjectKey
            ExistsInConfig = $true
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

    $ReturnCollection
}