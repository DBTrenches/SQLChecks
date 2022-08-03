#Requires -Modules @{ModuleName='SqlChecks';ModuleVersion='2.0';Guid='998f41a0-c4b4-4ec5-9e11-cb807d98d969'}

Describe "All SqlLibrary files should have a corresponding Tag" {
    It "<_>" -ForEach ($DxSqlLibrary.GetEnumerator().Name | Where-Object {$_ -NotLike '_Utility.*'} | Sort-Object) {
        $_ | Should -BeIn ([DxTagGenerator]::New().GetValidValues()) 
    }
}

Describe "All Tags should have a SqlLibrary entry" {
    It "<_>" -ForEach ([DxTagGenerator]::New().GetValidValues() | Sort-Object) {
        $DxSqlLibrary.GetEnumerator().Name | Should -Contain $_
    }
}
