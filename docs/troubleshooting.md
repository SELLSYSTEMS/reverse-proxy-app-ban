# Troubleshooting

## Symptom: real client IP is correct in logs, but ban does not trigger

Interpretation:
- trusted proxy logic is probably already correct
- investigate threshold, timing window, persistence, or the test method instead

Check:
- effective `maxRetries`
- effective `windowMs`
- whether the requests are truly sequential and deterministic

## Symptom: startup logs show the wrong `maxRetries` or timing values

Interpretation:
- the live process did not pick up the new environment

Check:
- `systemctl daemon-reload`
- `systemctl show`
- startup logs after the latest start

## Symptom: the unit file on disk is correct, but runtime behavior is still old

Interpretation:
- disk config and live config diverged

Check:
- whether the service was actually restarted or started from the expected unit
- whether a drop-in or override still applies
- whether the startup log prints the old effective config

## Symptom: service manager says `active`, but users still see `502`, connection errors, or no usable response

Interpretation:
- the process may be running, but the service is not yet ready
- or the service started and then failed before a real response path was verified

Check:
- a real readiness response, not only `systemctl status`
- startup logs
- listener readiness
- reverse proxy upstream health

## Symptom: automation or flow calls an unban command, but the command does not exist locally

Interpretation:
- the repository reference implementation was documented, but the runtime interface was never installed or wired

Check:
- whether the target host has a local callable wrapper
- whether automation is calling the local runtime interface rather than assuming a Git path
- whether the deployment item is only `documented` rather than `installed` and `wired`

## Symptom: only `BASIC_AUTH_FAILURE` appears, but no `APP_BAN_SET`

Interpretation:
- either the threshold was not reached
- or the test method is noisy and non-deterministic

Check:
- use `curl` or a deterministic script instead of browser auth prompts
- confirm the number of requests actually sent
- confirm the current threshold

## Symptom: after unban, the service starts and says it restored bans from the state file

Interpretation:
- the old process probably rewrote stale in-memory bans back into the state file during shutdown

Fix:
1. stop service
2. modify state file
3. start service

Do not use `edit file -> restart`.

## Symptom: immediately after unban, `APP_BAN_HIT` appears again

Interpretation:
- either the old ban was never really cleared
- or a new ban was created immediately, especially in immediate-ban mode with `maxRetries=1`
- this risk is even more operationally painful when the default one-year ban posture is active

Check:
- whether the service was fully stopped before the state file edit
- whether the test client retried immediately after unban
- whether immediate-ban mode is active
- whether the ban duration is the intended long-lived value such as `31536000000`

Important note:
- with browser Basic Auth prompts, the browser may not ask again cleanly after unban
- it may replay cached credentials or trigger hidden retries
- with `AUTH_BAN_MAX_RETRIES=1`, that single replay is enough to create a fresh one-year ban if `AUTH_BAN_DURATION_MS=31536000000`

## Symptom: wrong IP is being banned

Interpretation:
- either trusted proxy configuration is wrong
- or proxy header handling is too permissive

Check:
- peer IP seen by the app
- trusted proxy allowlist
- whether `X-Forwarded-For` is ignored for non-trusted peers

## Symptom: watcher produces no alerts even though app events exist

Interpretation:
- enforcement may be working, but downstream integration is missing or mismatched
- or the watcher process is stale even though it still appears active

Check:
- canonical event names and fields
- webhook delivery path
- TLS verification mode for local HTTPS
- downstream dedupe or filtering rules
- freshness of watcher-owned logs
- proof that new source events are still being consumed
