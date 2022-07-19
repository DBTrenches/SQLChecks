
using System.Management.Automation;

public class DxTagGenerator : IValidateSetValuesGenerator
{
    public string[] GetValidValues()
    {
        string[] Tags = new string[]
        {
                "Management.NumErrorLogs",
                "Management.Xevents",
                "Service.TraceFlags",
                "Service.SysConfigurations",
                "SqlAgent.Alerts",
                "SqlAgent.JobSchedules.Disabled",
                "SqlAgent.JobSchedules.NoneActive",
                "SqlAgent.Operators",
                "SqlAgent.Status"
        };

        return Tags;
    }
}
