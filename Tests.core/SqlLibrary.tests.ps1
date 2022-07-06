#Requires -Modules @{ModuleName='SqlChecks';ModuleVersion='2.0';Guid='998f41a0-c4b4-4ec5-9e11-cb807d98d969'}

Describe "All SqlLibrary files should have a corresponding Tag" {
    It "<_>" -ForEach ($DxQueryCollection.GetEnumerator().Name | Sort-Object) -Tag SqlAgent.Alerts {
        $_ | Should -BeIn ([ValidDxTagGenerator]::New().GetValidValues()) 
    }
}

Describe "All Tags should have a SqlLibrary entry" {
    It "<_>" -ForEach ([ValidDxTagGenerator]::New().GetValidValues() | Sort-Object) {
        $DxQueryCollection.GetEnumerator().Name | Should -Contain $_
    }
}
