# Availability Group Checks

These checks all require the config to have an `AvailabilityGroup` set.

## Can connect to the AG instance
```json
"AGInstanceConnectivity": {}
```

Checks that the server instance is pingable.  The server instance for an AG should typically be the listener.

## Number of synchronized secondary replicas
```json
"AGSyncCommitHealthStatus": {
  "NumberOfReplicas": 1
}
```

Verifies that there are least `NumberOfReplicas` in a `SYNCHRONIZED` state.  This does not count the primary, so in a toplogy with a single sync-commit secondary, the value to test for would be 1.
