# Install On Another Instance

## Preconditions

- You know the trusted proxy IP or IP range for that instance.
- The proxy overwrites or normalizes `X-Forwarded-For`.
- You are not committing any real secrets into this repository.

## Steps

1. Copy the app-layer ban logic into the target application.
2. Set the trusted proxy config for that instance.
3. Set generic auth-ban env vars.
4. Add watcher/alert parsing for:
- `BASIC_AUTH_FAILURE`
- `APP_BAN_SET`
- `APP_BAN_HIT`
- `APP_BAN_EXPIRED`
5. Disable any wrong container-local firewall enforcement that would ban the proxy IP instead of the real client IP.
6. Restart the service.
7. Verify with a real external wrong-auth test.

## Pass Criteria

- logs show the real external IP
- logs also preserve peer IP for forensics
- the ban is enforced by the application
- alerts are emitted for both ban creation and blocked requests

## Fail Cases

- the app still logs only the proxy IP
- the app trusts `X-Forwarded-For` from non-trusted peers
- the container firewall is still used as the main enforcement layer
- secrets or instance-specific values appear in repo content
