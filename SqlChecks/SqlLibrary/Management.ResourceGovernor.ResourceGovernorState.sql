select
    ClassifierFunction = concat(
                             object_schema_name(rg.classifier_function_id),
                             '.',
                             object_name(rg.classifier_function_id)
                         ),
    IsEnabled = rg.is_enabled,
    IsReconfigurationPending = convert(bit, dr.is_reconfiguration_pending)
from sys.resource_governor_configuration as rg
cross join sys.dm_resource_governor_configuration as dr;
