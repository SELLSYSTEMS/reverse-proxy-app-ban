# Install On Another Instance

## Preconditions

- You know the trusted proxy IP or IP range for that instance.
- The proxy overwrites or normalizes `X-Forwarded-For`.
- You are not committing any real secrets into this repository.
- You have identified whether a watcher already exists and whether it is read-only for this rollout.
- You understand the shutdown semantics of the target service if it persists ban state.

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

1. Copy the app-layer ban logic into the target application.
2. Set the trusted proxy config for that instance.
3. Set generic auth-ban env vars.
4. Decide the threshold mode explicitly:
- default for sensitive admin surfaces: `AUTH_BAN_MAX_RETRIES=1`
- use higher thresholds only if the deployment really needs them
5. Decide the duration mode explicitly:
- default for sensitive admin surfaces: `AUTH_BAN_DURATION_MS=31536000000`
- use shorter ban durations only if the deployment really needs them
6. Validate that the app logs effective startup config:
- `maxRetries`
- `windowMs`
- `durationMs`
- `blockStatus`
- trusted proxy mode
7. Add watcher/alert parsing for:
- `BASIC_AUTH_FAILURE`
- `APP_BAN_SET`
- `APP_BAN_HIT`
- `APP_BAN_EXPIRED`
8. Disable any wrong container-local firewall enforcement that would ban the proxy IP instead of the real client IP.
9. Reload systemd metadata if unit files changed.
10. Start or restart the service only after validating the intended install path.
11. Verify with a deterministic wrong-auth test.
12. Test manual unban with the standard stop-modify-start flow.

## Pass Criteria

- logs show the real external IP
- logs also preserve peer IP for forensics
- the ban is enforced by the application
- alerts are emitted for both ban creation and blocked requests
- live startup logs show the intended threshold and timing config
- live startup logs show the intended long-lived ban duration
- `systemctl show` agrees with the intended live environment
- manual unban works without stale bans returning on next start

## Fail Cases

- the app still logs only the proxy IP
- the app trusts `X-Forwarded-For` from non-trusted peers
- the container firewall is still used as the main enforcement layer
- secrets or instance-specific values appear in repo content
- the state file is edited while the old process is still running
- the unit file looks correct on disk but startup logs still show old values

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
