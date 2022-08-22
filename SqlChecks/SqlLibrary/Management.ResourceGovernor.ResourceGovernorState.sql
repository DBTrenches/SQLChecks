select      concat (
                object_schema_name (classifier_function_id)
               ,'.'
               ,object_name (classifier_function_id)) as ClassifierFunction
           ,is_enabled as IsEnabled
           ,cast(dr.is_reconfiguration_pending as bit) as IsReconfigurationPending
from        sys.resource_governor_configuration
outer apply (   select  drgc.is_reconfiguration_pending
                from    sys.dm_resource_governor_configuration as drgc) dr;
                