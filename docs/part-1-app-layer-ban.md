# Part 1: App-Layer Ban

## Objective

Block repeated authentication abuse using the real client IP, even when the app is behind a trusted proxy.

## Core Mechanism

1. Derive the real client IP from:
- trusted proxy peer + `X-Forwarded-For`
- or direct peer IP when no trusted proxy applies

2. On auth failure:
- log a normalized security event
- increment the failure bucket for that real client IP

3. When the threshold is reached:
- create an app-layer ban record
- persist it to a state file
- log `APP_BAN_SET`

4. On future requests from that client:
- block before auth processing
- log `APP_BAN_HIT`

5. When the ban expires:
- remove the record
- log `APP_BAN_EXPIRED`

## Recommended Config Surface

- `TRUST_PROXY_IPS`
- `AUTH_BAN_ENABLED`
- `AUTH_BAN_WINDOW_MS`
- `AUTH_BAN_MAX_RETRIES`
- `AUTH_BAN_DURATION_MS`
- `AUTH_BAN_BLOCK_STATUS`
- `AUTH_BAN_STATE_FILE`

Default posture for sensitive admin surfaces:
- `AUTH_BAN_MAX_RETRIES=1`
- one bad auth event immediately creates the ban
- higher thresholds are optional and should be documented as an explicit deployment choice

At startup, the application should log the effective values it actually loaded:
- `maxRetries`
- `windowMs`
- `durationMs`
- `blockStatus`
- trusted proxy mode

This is required for live validation after unit or drop-in changes.

## Why This Is Universal

This pattern does not depend on:
- one specific host IP
- one specific domain
- one specific organization

It depends only on one generic fact:
- the app knows which peer IPs are trusted proxies

## Required Observability

At minimum, log:
- `BASIC_AUTH_FAILURE`
- `APP_BAN_SET`
- `APP_BAN_HIT`
- `APP_BAN_EXPIRED`

Each event should preserve:
- real client IP
- peer IP
- forwarded IP if present
- path
- method
- expiry timestamp for ban events

## Event Sequence

Expected sequence during a deterministic test:

1. wrong auth attempt produces `BASIC_AUTH_FAILURE`
2. in immediate-ban mode, that same request also produces `APP_BAN_SET`
3. later requests during ban produce `APP_BAN_HIT`
4. expiry cleanup produces `APP_BAN_EXPIRED`

Watcher guidance:
- `APP_BAN_SET` is alert-worthy
- repeated `APP_BAN_HIT` is usually alert-worthy with dedupe
- `APP_BAN_EXPIRED` is useful for state transitions but often lower severity

## Manual Unban And Automation Unban

If bans are persisted, the unban sequence must be:

1. stop service
2. modify state file
3. start service

Do not use:

1. edit state file
2. restart service

Reason:
- the old process may save stale in-memory bans back into the state file during shutdown

Use the standard helper:
- `scripts/unban-app-layer-ip.sh`

## Deterministic Testing

Use:
- `curl`
- a small script
- repeatable CLI requests with explicit headers

Avoid relying on browser basic-auth prompts for threshold testing because they often add hidden retries, caching, or other noise that makes counters look inconsistent.

## Existing Watcher Integration

If a watcher or downstream flow already exists:
- treat it as read-only unless the user explicitly asks to change it
- emit canonical app-layer events in the format the watcher already expects
- validate delivery and field mapping instead of rewriting the watcher
