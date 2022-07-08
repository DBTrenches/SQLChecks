
using System.Management.Automation;

public class DxTagGenerator : IValidateSetValuesGenerator
{
    public string[] GetValidValues()
    {
        string[] Tags = new string[]
        {
                "SqlAgent.Alerts",
                "SqlAgent.Jobs.Schedules.NoneDisabled",
                "SqlAgent.Jobs.AllHaveOneActiveSchedule",
                "SqlAgent.Operators",
                "SqlAgent.Status",
                "CheckDuplicateIndexes",
                "CheckForIdentityColumnLimit",
                "CheckUnconfiguredSQLAgentAlerts"
        };

        return Tags;
    }
}
