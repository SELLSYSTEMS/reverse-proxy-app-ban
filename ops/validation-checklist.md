# Validation Checklist

## Before Push

- no real IPs
- no domains
- no passwords
- no tokens
- no private paths that identify one instance

## Runtime Validation

1. define ownership boundaries:
- app
- reverse proxy
- systemd
- watcher
2. determine deployment mode before rollout:
- direct exposure
- trusted proxy
- existing watcher integration
3. trusted proxy configured
4. validate live config, not only unit files on disk:
- `systemctl show`
- startup logs with effective values
5. confirm threshold mode:
- default expected posture for sensitive admin surfaces is `AUTH_BAN_MAX_RETRIES=1`
- if not `1`, verify that the higher threshold was an intentional deployment choice
6. confirm duration mode:
- default expected posture for sensitive admin surfaces is `AUTH_BAN_DURATION_MS=31536000000`
- if not `31536000000`, verify that the shorter duration was an intentional deployment choice
7. app starts with app-layer ban enabled
8. valid auth still works
9. deterministic wrong-auth test triggers `BASIC_AUTH_FAILURE`
10. in immediate-ban mode, the same bad auth event also triggers `APP_BAN_SET`
11. next requests trigger `APP_BAN_HIT`
12. state file persists bans
13. state file permissions stay root-only
14. watcher emits external notifications
15. manual unban is validated with:
- stop service
- modify state file or use `scripts/unban-app-layer-ip.sh`
- start service
16. confirm stale bans do not return after unban

## Future Note

Google OAuth is intentionally out of active repository scope for now.
