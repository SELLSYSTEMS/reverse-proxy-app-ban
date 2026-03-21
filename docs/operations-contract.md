# Operations Contract

This document defines the environment-agnostic contracts that future operators and AI agents must satisfy when turning this repository into a working deployment.

## 0. Authority Order

When deciding what is true about a current deployment, use this order:

1. live host facts
2. current service logs
3. current persisted state
4. current live environment
5. repository documentation
6. handoff notes

This rule exists because handoffs age quickly and repository docs describe the intended contract, not the exact current runtime.

## 1. Abstract Deployment Data Model

Before installation, collect these values in abstract form:

- application service name
- service manager type
- trusted proxy source model:
  - direct exposure
  - fixed proxy IPs
  - proxy IP range
- auth-ban config values:
  - enabled
  - window
  - threshold
  - duration
  - block status
- state backend:
  - persisted file path or equivalent storage
  - shutdown semantics
- watcher mode:
  - no watcher yet
  - existing watcher, read-only
  - existing watcher, editable by request
- local automation entrypoints:
  - unban command
  - service restart command
  - service status command
  - readiness check command

Do not encode one host's filesystem layout as if it were universal. Preserve the contract, not the local path.

## 2. Runtime Interface Contract

If the deployment includes local automation or downstream flows, define and verify a runtime interface.

Minimum expected interfaces:

- unban one IP
- restart or start the protected service
- inspect live service status
- validate service readiness

Important distinction:
- repository reference implementation:
  example logic or script kept in version control
- runtime automation entrypoint:
  the local command that the host actually invokes

These are not automatically the same thing. A deployment is incomplete if a flow calls a runtime command that was never installed.

## 3. Deployment Completion Matrix

Treat each item as a separate status:

- documented:
  guidance exists in the repository
- installed:
  code or script exists on the target host
- wired:
  local flows, wrappers, or operators invoke the correct runtime interface
- live-verified:
  the installed and wired behavior was tested successfully against the running service

Do not report success when only `documented` or `installed` is true.

## 4. Readiness Gate

After any restart or start, do not stop at `service active`.

Readiness requires all of these:

- service manager reports running
- startup log shows the intended effective config
- the service responds on its real listener
- valid auth still works
- protected behavior still works

Example interpretation:
- `active` but `502` from the reverse proxy means `not ready`
- `active` but no listener response means `not ready`
- `active` but wrong startup values means `running with wrong config`

## 4A. Mandatory Pre-Change Verification Gate

Before any restart, rewrite, or rollout, gather read-only evidence for:

- current live environment
- current startup log with effective config
- current persisted state
- current readiness result
- current watcher freshness if alerting is in scope

If those checks already answer the question, mutation is not justified.

## 4B. Restart Is Not A Discovery Tool

An AI agent must not restart a service just to learn facts that could have been gathered read-only.

A restart is justified only when:

- a real config change requires it
- the service is already broken and restoration is the task
- the user explicitly wants the restart after the current state was established

## 5. Watcher Liveness Contract

A watcher or alerting bridge is not healthy just because its process is `active`.

Watcher liveness requires:

- process is running
- it is still consuming fresh source events
- it is still writing fresh own logs or metrics
- it is still performing outbound delivery successfully

If new security events appear in the protected service logs but the watcher emits nothing new, treat the watcher as stale even if `systemctl status` says `active`.

## 6. Interruption Safety

Operations that stop a service and later start it again are interruption-sensitive.

Safe patterns:

- one wrapper performs the full sequence atomically
- or the operator explicitly verifies final service state after each step

Required mindset:
- after `stop`, assume the service may remain down if the workflow aborts
- after `start`, assume the service may still be not ready until proven otherwise

## 6A. Handoff Invalidation

Treat handoff as stale after any of these:

- service restart
- unit or drop-in change
- application rewrite
- persisted state change
- watcher or flow change

Once stale, handoff can suggest what to verify, but it cannot define what is true.

## 7. Anti-Ambiguity Rule For Future AI Agents

When adapting this repository to another environment, always answer these questions explicitly:

1. What is the real runtime command the operator or flow will call?
2. Where does the service get its live config from?
3. How is readiness proven?
4. How is watcher freshness proven?
5. Which parts are only references in Git, and which parts are actually installed and wired?

If any of those answers is missing, the deployment instructions are incomplete.
