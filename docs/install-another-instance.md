# Install On Another Instance

## Preconditions

- You know the trusted proxy IP or IP range for that instance.
- The proxy overwrites or normalizes `X-Forwarded-For`.
- You are not committing any real secrets into this repository.
- You have identified whether a watcher already exists and whether it is read-only for this rollout.
- You understand the shutdown semantics of the target service if it persists ban state.

## First Rule On A New Host

Do not act from handoff first.

Before any restart or rewrite:
- verify the live environment
- verify the current startup log
- verify the current persisted state
- verify a real readiness response

If those four sources already prove the runtime state, the agent must use them instead of calling the state unknown.

## Abstract Data To Collect

Collect these environment-specific facts before installation:

- logical service name
- live config source:
  unit file, drop-in, env file, container env, or equivalent
- trusted proxy model
- state backend type and location
- local runtime automation command names
- watcher mode:
  absent, existing-read-only, or editable-by-request
- readiness check method

The exact paths can vary per environment. The important part is that each role exists and is mapped explicitly.

## Runtime Interface Contract

Before wiring automation or flows, verify that the target environment has working local entrypoints for:

- unban one IP
- inspect service status
- restart or start the service
- check readiness

Do not assume that a script documented in Git already exists on the target host under a callable local name.

## Choose Install Path First

Before editing anything, classify the target instance:

1. No existing watcher:
- install app-layer events and the watcher integration path together

2. Existing watcher already in production:
- keep the watcher read-only
- only emit canonical webhook events from the app
- validate delivery and formatting

3. Directly exposed app without trusted proxy:
- use direct peer IP and skip `X-Forwarded-For` trust logic

4. App behind trusted proxy or host bridge:
- use trusted-proxy-aware real IP derivation

## Steps

1. Complete the read-only verification gate first.
2. Copy the app-layer ban logic into the target application only if the target does not already implement the required behavior.
3. Set the trusted proxy config for that instance.
4. Set generic auth-ban env vars.
5. Decide the threshold mode explicitly:
- default for sensitive admin surfaces: `AUTH_BAN_MAX_RETRIES=1`
- use higher thresholds only if the deployment really needs them
6. Decide the duration mode explicitly:
- default for sensitive admin surfaces: `AUTH_BAN_DURATION_MS=31536000000`
- use shorter ban durations only if the deployment really needs them
7. Validate that the app logs effective startup config:
- `maxRetries`
- `windowMs`
- `durationMs`
- `blockStatus`
- trusted proxy mode
8. Add watcher/alert parsing for:
- `BASIC_AUTH_FAILURE`
- `APP_BAN_SET`
- `APP_BAN_HIT`
- `APP_BAN_EXPIRED`
9. Disable any wrong container-local firewall enforcement that would ban the proxy IP instead of the real client IP.
10. Reload systemd metadata only if unit files changed.
11. Start or restart the service only when there is a concrete change to apply or restoration is required.
12. Verify with a deterministic wrong-auth test.
13. Test manual unban with the standard stop-modify-start flow.

## Deployment Completion Matrix

Do not stop at "documentation exists".

Track each installation item as:

- documented
- installed
- wired into automation or flows
- live-verified

Example:
- a repository script may be `documented`
- a copied local wrapper may be `installed`
- a Node-RED flow or operator command may make it `wired`
- only a real successful unban and readiness proof makes it `live-verified`

## Pass Criteria

- logs show the real external IP
- logs also preserve peer IP for forensics
- the ban is enforced by the application
- alerts are emitted for both ban creation and blocked requests
- live startup logs show the intended threshold and timing config
- live startup logs show the intended long-lived ban duration
- `systemctl show` agrees with the intended live environment
- readiness is proven by a real service response, not only by `active`
- watcher freshness is proven by fresh own logs or successful outbound delivery
- manual unban works without stale bans returning on next start

## Fail Cases

- the app still logs only the proxy IP
- the app trusts `X-Forwarded-For` from non-trusted peers
- the container firewall is still used as the main enforcement layer
- secrets or instance-specific values appear in repo content
- the state file is edited while the old process is still running
- the unit file looks correct on disk but startup logs still show old values
- the runtime wrapper expected by automation does not actually exist on the host
- the service is `active` but still not ready
- the watcher process is `active` but stale

## Webhook Transport Variants

Common transport patterns:

- local plain HTTP:
  simplest for same-host or same-network delivery
- local HTTPS with self-signed certificate:
  acceptable for local infrastructure when you explicitly handle trust
- local HTTPS with local CA:
  preferable when you want verification without `skip verify`

Guidance:
- if you must use self-signed local HTTPS during bootstrap, document when `skip verify` is used and why
- if the watcher stack is stable, prefer trusting a local CA instead of leaving permanent `skip verify`
