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
