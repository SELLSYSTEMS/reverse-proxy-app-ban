# State Model

This project has three distinct state sources. They must not be treated as interchangeable.

## 1. Live systemd environment

Examples:
- `TRUST_PROXY_IPS`
- `AUTH_BAN_WINDOW_MS`
- `AUTH_BAN_MAX_RETRIES`
- `AUTH_BAN_DURATION_MS`
- `AUTH_BAN_BLOCK_STATUS`
- `AUTH_BAN_STATE_FILE`

Properties:
- loaded when the service process starts
- may differ from the unit file on disk if the process was not restarted or reloaded correctly
- should be validated through `systemctl show` and startup logs, not only by reading the unit file

## 2. In-memory runtime state

Examples:
- failure counters
- active ban records
- computed expiry timestamps

Properties:
- exists only inside the running process
- may diverge from the persisted state file until the next save operation
- may be written back to disk on graceful shutdown

## 3. Persisted state file

Examples:
- JSON file holding active bans and related metadata

Properties:
- survives restarts
- is loaded by the process during startup
- may be overwritten by the old process during shutdown if it flushes its in-memory state

## Critical Shutdown Semantics

If the service saves in-memory ban state during `SIGTERM` or normal shutdown, then this sequence is unsafe:

1. edit state file
2. restart service

Why it is unsafe:
- the old process may still hold stale bans in memory
- during shutdown it may save those stale bans back into the state file
- the new process then starts and reloads the stale bans you thought you removed

## Safe Unban Sequence

Always use this order:

1. stop service
2. modify state file
3. start service

This is the required model for manual unban and for automated unban tooling.

## Live Config Validation

After changing any unit file or drop-in:

1. validate the file on disk
2. run `systemctl daemon-reload` if needed
3. validate the live unit properties with `systemctl show`
4. validate startup logs for effective runtime config

At startup, the app should log effective values for:
- `maxRetries`
- `windowMs`
- `durationMs`
- `blockStatus`
- trusted proxy mode
