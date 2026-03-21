# Agent Guidance

This repository is written for future AI agents, including OpenAI Codex CLI.

## Mission

Maintain a universal, reusable reverse-proxy-aware protection project.

## Hard Rules

- Never commit sensitive instance data.
- Never commit real host IPs, domains, passwords, cookies, or tokens.
- Keep all examples generic and parameterized.
- For sensitive admin surfaces, assume immediate-ban mode by default unless the deployment explicitly requires a higher threshold.
- For the main admin-surface pattern documented in this repository, assume a one-year ban by default unless the deployment explicitly requires a shorter duration.
- Define ownership boundaries before changing anything:
  - app layer
  - reverse proxy / host bridge
  - systemd / service manager
  - watcher / downstream alerting flow
- Always distinguish:
  - `peer IP`: the immediate network source seen by the app
  - `real client IP`: the external IP derived from trusted proxy headers
- Never assume the trusted proxy IP is fixed. It must be configurable.
- Keep Google OAuth only as a future note for now, not as active repository scope.
- Do not change an existing downstream watcher or flow unless the user explicitly asks for it.
- First determine the existing deployment mode, then choose the install path. Do not force one rollout pattern onto every instance.
- If persisted ban state exists, verify shutdown semantics before automating unban or ban maintenance.

## Documentation Standard

Every change should keep these concepts obvious:
- where enforcement happens
- why container-local firewall enforcement may be wrong
- how trusted proxy IPs are configured
- how the real client IP is derived
- how bans are persisted, expired, removed, and validated
- how live systemd env differs from in-memory runtime state and persisted state file contents
- how manual and automated unban work without reintroducing stale bans
- which runtime interfaces must exist on the target host
- how deployment completion is measured beyond "docs exist"

## Current Strategic Structure

- Current active scope: Part 1 only
- Part 1: app-layer ban for password/auth abuse behind a trusted proxy
- Future note only: Google OAuth may become the next layer later, but it does not belong to the active repo scope yet

The repository should stay step-by-step and composable so another AI agent can pick it up without hidden context, but without prematurely documenting unfinished later parts as if they already belong to the repo.

## Operational Guardrails For AI Agents

- Never silently keep code defaults if they contradict the documented security posture. Validate live values for both retry threshold and ban duration.
- The strongest documented default in this repository is:
  - `AUTH_BAN_MAX_RETRIES=1`
  - `AUTH_BAN_DURATION_MS=31536000000`
- Distinguish `reference implementation in Git` from `runtime command installed on host`.
- Before calling a local automation command, verify that the target environment actually has that runtime interface installed and callable.
- Track deployment status using four separate states:
  - documented
  - installed
  - wired
  - live-verified
- Do not assume a correct unit file on disk means the live process is using that config.
- Validate runtime config through `systemctl show`, process environment when appropriate, and startup logs.
- Do not confuse `service active` with `service ready`. Require a real readiness check.
- Do not confuse `watcher active` with `watcher healthy`. Require proof of fresh source consumption and successful outbound delivery.
- Prefer deterministic tests such as `curl` or a small script over browser basic-auth prompts when checking counters and threshold behavior.
- If `realClientIp` is correct in logs but ban logic does not trigger, stop investigating trusted proxy logic first and move to threshold, persistence, or test-method analysis.
- If unban appears to work but bans come back on the next start, suspect shutdown-time state persistence before suspecting the state file editor.
- If a workflow includes `stop -> modify -> start`, treat interruption as part of the design. The agent is responsible for confirming the final runtime state before declaring success.
