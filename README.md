# reverse-proxy-app-ban

Universal app-layer ban pattern for services that run behind a trusted reverse proxy or host bridge.

## Goal

Provide a reusable security design for systems where:
- the application runs inside a container or LXC
- the direct network peer is a host or reverse proxy
- the real client IP is available only through `X-Forwarded-For`
- network-layer banning inside the container is incorrect or ineffective

This repository is intentionally generic:
- no instance IPs
- no domains
- no passwords
- no private tokens

## Project Scope Right Now

- Active scope: Part 1 only
- Part 1: trusted-proxy-aware app-layer ban for wrong password/auth abuse
- Future note only: Google OAuth may be added later as the next auth layer

## Default Security Posture

This repository defaults to immediate-ban mode for sensitive admin surfaces.

Meaning:
- one bad auth event can be enough to set a ban
- `AUTH_BAN_MAX_RETRIES=1` is the default example posture
- `AUTH_BAN_DURATION_MS=31536000000` is the default example posture for a one-year ban
- higher retry thresholds should be treated as an explicit deployment choice, not as the default assumption
- shorter ban durations should also be treated as an explicit deployment choice, not as the default assumption

## Critical Operator Warning

For the primary admin-surface use case documented in this repository, the intended posture is:
- first wrong password attempt triggers the ban immediately
- that ban lasts for one year

Translated to config:
- `AUTH_BAN_MAX_RETRIES=1`
- `AUTH_BAN_DURATION_MS=31536000000`

Do not let a future AI agent silently fall back to:
- multiple retries
- one-hour bans
- browser-based testing that immediately re-bans the client due to hidden retries or cached credentials

## Repository Layout

- `AGENTS.md`: instructions for future AI agents such as OpenAI Codex CLI
- `docs/architecture.md`: system model and trust boundaries
- `docs/state-model.md`: live env vs in-memory records vs persisted state
- `docs/part-1-app-layer-ban.md`: complete design for app-layer ban
- `docs/install-another-instance.md`: installation procedure for another instance
- `docs/troubleshooting.md`: symptom-based troubleshooting matrix
- `scripts/unban-app-layer-ip.sh`: standard stop-modify-start unban CLI
- `templates/claude-vnc-terminal.service.example`: safe example unit template
- `ops/validation-checklist.md`: rollout and verification checklist

## Design Principle

If the real client IP exists only in `X-Forwarded-For`, then banning inside the container firewall is the wrong enforcement layer.

Correct enforcement options:
- app-layer ban inside the application, using real client IP derived from a trusted proxy
- host or reverse-proxy layer ban outside the container

This repository starts with the app-layer approach.

## Operational Notes

- Persisted ban state introduces shutdown semantics. A service may write its current in-memory ban records back to disk on `SIGTERM`.
- Because of that, manual unban is not `edit file -> restart`. The safe order is always `stop service -> modify state file -> start service`.
- Validating only the unit file on disk is insufficient. Validate the live process through both `systemctl show` and startup logs.
- If a downstream watcher or flow already exists, treat it as read-only unless the user explicitly asks to change it.
