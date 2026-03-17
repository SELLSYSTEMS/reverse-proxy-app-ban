# Part 1: App-Layer Ban

## Objective

Block repeated authentication abuse using the real client IP, even when the app is behind a trusted proxy.

## Core Mechanism

1. Derive the real client IP from:
- trusted proxy peer + `X-Forwarded-For`
- or direct peer IP when no trusted proxy applies

2. On auth failure:
- log a normalized security event
- increment the failure bucket for that real client IP

3. When the threshold is reached:
- create an app-layer ban record
- persist it to a state file
- log `APP_BAN_SET`

4. On future requests from that client:
- block before auth processing
- log `APP_BAN_HIT`

5. When the ban expires:
- remove the record
- log `APP_BAN_EXPIRED`

## Recommended Config Surface

- `TRUST_PROXY_IPS`
- `AUTH_BAN_ENABLED`
- `AUTH_BAN_WINDOW_MS`
- `AUTH_BAN_MAX_RETRIES`
- `AUTH_BAN_DURATION_MS`
- `AUTH_BAN_BLOCK_STATUS`
- `AUTH_BAN_STATE_FILE`

## Why This Is Universal

This pattern does not depend on:
- one specific host IP
- one specific domain
- one specific organization

It depends only on one generic fact:
- the app knows which peer IPs are trusted proxies

## Required Observability

At minimum, log:
- `BASIC_AUTH_FAILURE`
- `APP_BAN_SET`
- `APP_BAN_HIT`
- `APP_BAN_EXPIRED`

Each event should preserve:
- real client IP
- peer IP
- forwarded IP if present
- path
- method
- expiry timestamp for ban events
