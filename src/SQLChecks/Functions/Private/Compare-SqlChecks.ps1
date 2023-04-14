function Compare-SqlChecks {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        $ReferenceObject,
        
        [Parameter(Mandatory)]
        $DifferenceObject
    )

    $comparison = @(Compare-Object -ReferenceObject $ReferenceObject -DifferenceObject $DifferenceObject)

    foreach ($delta in $comparison) {
        [pscustomobject]@{
            Value = $delta.InputObject
            Issue = if ($delta.SideIndicator -eq "<=") { "Missing from target" } else { "Extra on target" }
        }
    }
}