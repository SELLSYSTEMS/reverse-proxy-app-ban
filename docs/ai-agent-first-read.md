# AI Agent First Read

Read this file before touching any live deployment that uses this repository.

## Mandatory Read Order

1. `README.md`
2. `docs/live-authority-protocol.md`
3. `ops/validation-checklist.md`
4. only then the deeper design and install documents

If you skip that order, you are likely to repeat old rollout mistakes.

## Seven Non-Negotiables

1. Live facts outrank handoff.
- Do not call runtime state "unknown" if current logs, persisted state, live env, and a real response already prove it.

2. Restart is not a discovery tool.
- Do not restart a service just to learn facts that can be collected read-only.

3. Read-only gate comes before mutation.
- Verify live env, startup log, persisted state, readiness, and watcher freshness before changing anything.

4. Missing credentials are not wrong credentials.
- A request with no `Authorization: Basic ...` header may return `401`.
- It must not emit `BASIC_AUTH_FAILURE`.
- It must not increment failure counters.
- It must not create a ban.

5. Default admin-surface posture is immediate and long-lived.
- `AUTH_BAN_MAX_RETRIES=1`
- `AUTH_BAN_DURATION_MS=31536000000`
- For the main pattern documented here, one explicit wrong password attempt creates a one-year ban.

6. Unban is stop -> modify -> start.
- If persisted ban state exists, do not use `edit file -> restart`.
- The old process may rewrite stale bans during shutdown.

7. Default operator alerting is ban-focused.
- `APP_BAN_SET` should normally notify the operator.
- `APP_BAN_HIT`, `BASIC_AUTH_FAILURE`, expiry, and health-style signals are optional and often too noisy by default.

## Required Stop Point

After the read-only gate, stop and determine what the operator wants next:
- ready for manual test
- or explicit live adversarial exercise

Do not consume the live test window by running your own bad-auth cycle unless the operator explicitly asked for it.

## Common Failure Patterns To Avoid

- "The runtime is unknown, so I will restart and inspect after."
- "The unit file looks correct, so the live process must already use it."
- "A browser refresh or background request caused a ban, so the user must have entered a wrong password."
- "No `Authorization` header still counts as a failed auth attempt."
- "Every `APP_BAN_HIT` must page the operator."
- "The repository script path is the same thing as a host-installed runtime command."

## Success Condition

A future AI agent should be able to say:
- I proved the live state read-only first.
- I did not restart for discovery.
- I did not treat missing credentials as wrong credentials.
- I stopped at the operator checkpoint unless explicit live testing was requested.
- I kept default alerting ban-focused unless the operator asked for more noise.
