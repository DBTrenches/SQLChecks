function Get-DxQuery {
<#
.SYNOPSIS
    Get the SQL Library Query for a $Tag

.DESCRIPTION
    The $DxSqlLibrary module variable is a dictionary with an entry for every
    valid $Tag (it also includes non-valid tags but those cannot be returned
    from this function). 
#>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)]
        [ValidateSet([DxTagGenerator])]
        [string]$Tag
    )

    $DxSqlLibrary[$Tag].QueryText
}
