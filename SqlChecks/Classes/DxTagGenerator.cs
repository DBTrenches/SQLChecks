using System.Management.Automation;

public class DxTagGenerator : IValidateSetValuesGenerator
{
    public string[] GetValidValues()
    {
        string[] Tags = new string[]
        {
            "_Utility.select1",
            "Databases.DuplicateIndexes",
            "Databases.Files.SpaceUsed",
            "Databases.IdentityColumnLimit",
            "Databases.OversizedIndexes",
            "Management.DbMail.DefaultProfile",
            "Management.NumErrorLogs",
            "Management.Xevents",
            "Security.SysAdmins",
            "Service.InstantFileInitializationSetting",
            "Service.SysConfigurations",
            "Service.TempDbConfiguration",
            "Service.TraceFlags",
            "SqlAgent.Alerts",
            "SqlAgent.JobSchedules.Disabled",
            "SqlAgent.JobSchedules.NoneActive",
            "SqlAgent.Operators",
            "SqlAgent.Status",
            "Service.CommittedMemory"
        };

        return Tags;
    }
}
