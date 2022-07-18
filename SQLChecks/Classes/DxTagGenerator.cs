
using System.Management.Automation;

public class DxTagGenerator : IValidateSetValuesGenerator
{
    public string[] GetValidValues()
    {
        string[] Tags = new string[]
        {
                "SqlAgent.Alerts",
                "SqlAgent.Jobs.Schedules.Disabled",
                "SqlAgent.Jobs.Schedules.NoneActive",
                "SqlAgent.Operators",
                "SqlAgent.Status",
                "CheckDuplicateIndexes",
                "CheckForIdentityColumnLimit",
                "CheckUnconfiguredSQLAgentAlerts"
        };

        return Tags;
    }
}
