
using System.Management.Automation;

public class DxTagGenerator : IValidateSetValuesGenerator
{
    public string[] GetValidValues()
    {
        string[] Tags = new string[]
        {
                "Service.TraceFlags",
                "SqlAgent.Alerts",
                "SqlAgent.Jobs.Schedules.Disabled",
                "SqlAgent.Jobs.Schedules.NoneActive",
                "SqlAgent.Operators",
                "SqlAgent.Status"
        };

        return Tags;
    }
}
