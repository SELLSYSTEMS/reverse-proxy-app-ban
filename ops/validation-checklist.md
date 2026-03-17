# Validation Checklist

## Before Push

- no real IPs
- no domains
- no passwords
- no tokens
- no private paths that identify one instance

## Runtime Validation

1. trusted proxy configured
2. app starts with app-layer ban enabled
3. valid auth still works
4. repeated wrong auth triggers `APP_BAN_SET`
5. next requests trigger `APP_BAN_HIT`
6. state file persists bans
7. state file permissions stay root-only
8. watcher emits external notifications

## Future Note

Google OAuth is intentionally out of active repository scope for now.
