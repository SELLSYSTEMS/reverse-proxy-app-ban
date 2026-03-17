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

## Repository Layout

- `AGENTS.md`: instructions for future AI agents such as OpenAI Codex CLI
- `docs/architecture.md`: system model and trust boundaries
- `docs/part-1-app-layer-ban.md`: complete design for app-layer ban
- `docs/install-another-instance.md`: installation procedure for another instance
- `templates/claude-vnc-terminal.service.example`: safe example unit template
- `ops/validation-checklist.md`: rollout and verification checklist

## Design Principle

If the real client IP exists only in `X-Forwarded-For`, then banning inside the container firewall is the wrong enforcement layer.

Correct enforcement options:
- app-layer ban inside the application, using real client IP derived from a trusted proxy
- host or reverse-proxy layer ban outside the container

This repository starts with the app-layer approach.
