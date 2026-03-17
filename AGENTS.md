# Agent Guidance

This repository is written for future AI agents, including OpenAI Codex CLI.

## Mission

Maintain a universal, reusable reverse-proxy-aware protection project.

## Hard Rules

- Never commit sensitive instance data.
- Never commit real host IPs, domains, passwords, cookies, or tokens.
- Keep all examples generic and parameterized.
- Always distinguish:
  - `peer IP`: the immediate network source seen by the app
  - `real client IP`: the external IP derived from trusted proxy headers
- Never assume the trusted proxy IP is fixed. It must be configurable.
- Keep Google OAuth only as a future note for now, not as active repository scope.

## Documentation Standard

Every change should keep these concepts obvious:
- where enforcement happens
- why container-local firewall enforcement may be wrong
- how trusted proxy IPs are configured
- how the real client IP is derived
- how bans are persisted, expired, removed, and validated

## Current Strategic Structure

- Current active scope: Part 1 only
- Part 1: app-layer ban for password/auth abuse behind a trusted proxy
- Future note only: Google OAuth may become the next layer later, but it does not belong to the active repo scope yet

The repository should stay step-by-step and composable so another AI agent can pick it up without hidden context, but without prematurely documenting unfinished later parts as if they already belong to the repo.
