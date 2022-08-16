select 
    s.[name] as [Name], 
    s.event_retention_mode_desc as EventRetentionModeDesc,
    s.max_dispatch_latency as MaxDispatchLatency,
    s.max_memory as MaxMemory,
    s.max_event_size as MaxEventSize,
    s.memory_partition_mode_desc as MemoryPartitionModeDesc,
    s.startup_state as StartupState
from sys.server_event_sessions as s
