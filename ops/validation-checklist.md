# Validation Checklist

## Before Push

- no real IPs
- no domains
- no passwords
- no tokens
- no private paths that identify one instance

## Runtime Validation

1. complete read-only verification before any mutation:
- live environment
- current startup log
- current persisted state
- real readiness response
2. define ownership boundaries:
- app
- reverse proxy
- systemd
- watcher
3. determine deployment mode before rollout:
- direct exposure
- trusted proxy
- existing watcher integration
4. trusted proxy configured
5. validate live config, not only unit files on disk:
- `systemctl show`
- startup logs with effective values
6. confirm runtime automation interfaces exist on the host:
- unban command
- service status command
- service restart/start command
- readiness check command
7. confirm deployment completion state for each critical item:
- documented
- installed
- wired
- live-verified
8. confirm threshold mode:
- default expected posture for sensitive admin surfaces is `AUTH_BAN_MAX_RETRIES=1`
- if not `1`, verify that the higher threshold was an intentional deployment choice
9. confirm duration mode:
- default expected posture for sensitive admin surfaces is `AUTH_BAN_DURATION_MS=31536000000`
- if not `31536000000`, verify that the shorter duration was an intentional deployment choice
10. app starts with app-layer ban enabled
11. service readiness is proven by a real response, not just `active`
12. valid auth still works
13. deterministic wrong-auth test triggers `BASIC_AUTH_FAILURE`
14. in immediate-ban mode, the same bad auth event also triggers `APP_BAN_SET`
15. next requests trigger `APP_BAN_HIT`
16. state file persists bans
17. state file permissions stay root-only
18. watcher emits external notifications
19. watcher health is proven by fresh own logs or successful outbound delivery
20. restart was performed only because a real change required it or restoration was needed
21. manual unban is validated with:
- stop service
- modify state file or use `scripts/unban-app-layer-ip.sh`
- start service
22. confirm stale bans do not return after unban

## Future Note

Google OAuth is intentionally out of active repository scope for now.
