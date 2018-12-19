# Availability Group Checks

These checks all require the config to have an `AvailabilityGroup` set.  Some of these checks execute at the instance level, some at the AG level, and some for each database in the AG.  All checks are related to the health and/or configuration of the AG and its constituent databases.

## Can connect to the AG instance
```json
"AGInstanceConnectivity": {}
```

Checks that the server instance is pingable.  The server instance for an AG should typically be the listener.

## Primary synchronization status

```json
"AGPrimaryHealthStatus": {}
```

Checks the status of the primary replica is `SYNCHRONIZED`.

## Number of synchronized secondary replicas
```json
"AGSyncCommitHealthStatus": {
  "NumberOfReplicas": 1
}
```

Verifies that there are least `NumberOfReplicas` in a `SYNCHRONIZED` state.  This does not count the primary, so in a toplogy with a single sync-commit secondary, the value to test for would be 1.