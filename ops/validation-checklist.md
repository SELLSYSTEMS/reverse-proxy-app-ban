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
6. app starts with app-layer ban enabled
7. valid auth still works
8. deterministic wrong-auth test triggers `BASIC_AUTH_FAILURE`
9. in immediate-ban mode, the same bad auth event also triggers `APP_BAN_SET`
10. next requests trigger `APP_BAN_HIT`
11. state file persists bans
12. state file permissions stay root-only
13. watcher emits external notifications
14. manual unban is validated with:
- stop service
- modify state file or use `scripts/unban-app-layer-ip.sh`
- start service
15. confirm stale bans do not return after unban

## Future Note

Google OAuth is intentionally out of active repository scope for now.
