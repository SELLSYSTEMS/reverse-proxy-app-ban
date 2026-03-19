# Architecture

## Problem Shape

Some applications run behind a main host or reverse proxy and see that proxy as the direct peer.

Example pattern:

```text
external client -> main host / reverse proxy -> container or LXC -> app
```

In this model:
- the app may see only the proxy IP at the socket layer
- the real client IP may exist only in `X-Forwarded-For`

## Ownership Boundaries

Define these boundaries before changing an instance:

- App layer:
  derives real client IP, counts failures, enforces bans, persists ban state
- Reverse proxy or host bridge:
  decides whether `X-Forwarded-For` is normalized and which peer IPs are trusted
- systemd or service manager:
  supplies live environment variables and controls stop/start semantics
- Watcher or downstream alerting flow:
  consumes canonical events and notifies elsewhere

These layers should not be merged casually during installation work. In particular, an existing watcher is often an integration target, not something to rewrite.

## Trust Boundary

`X-Forwarded-For` must be trusted only when the direct peer IP is in the configured trusted proxy list.

Rules:
- peer in `TRUST_PROXY_IPS` -> use `X-Forwarded-For` as real client IP
- peer not in `TRUST_PROXY_IPS` -> ignore `X-Forwarded-For`, use direct peer IP

## Enforcement Decision

Container-local firewall banning is wrong when:
- all traffic reaches the app from the host or proxy IP
- the container cannot see the real client IP at the packet level

In that case, use:
- app-layer enforcement inside the service
- or host/proxy-layer enforcement outside the container

This project uses app-layer enforcement for Part 1.

## Deployment-Mode Decision

Before installation, determine which mode applies:

1. App behind trusted proxy or host bridge:
- use app-layer ban keyed to real client IP

2. App directly exposed to clients:
- app-layer ban still works, but host/proxy-layer enforcement may also be viable

3. Existing watcher already present:
- integrate with its canonical event format and keep it read-only unless instructed otherwise
