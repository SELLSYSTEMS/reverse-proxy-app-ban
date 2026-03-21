# Live Authority Protocol

This protocol exists to stop future AI agents from taking destructive or noisy actions based on stale handoffs, assumptions, or repository context.

## Source Of Truth Order

When sources disagree, trust them in this order:

1. current live host facts
2. current live service logs
3. current persisted runtime state
4. current service-manager live environment
5. repository documentation
6. handoff notes

Interpretation:

- handoff is never the top authority
- repository docs define the contract, not the current runtime
- the live host decides what is true right now

## Mandatory Read-Only Verification Gate

Before any restart, rewrite, or rollout, the AI agent must gather read-only evidence for all of these:

- current service-manager live environment
- current startup log showing effective config
- current persisted state
- current real response or readiness result
- current watcher freshness if alerting is part of the workflow

If those checks already prove the answer, the agent must not describe runtime state as unknown.

## Restart Prohibition Rule

Do not restart a service just to discover facts that can be learned read-only.

A restart is allowed only when at least one of these is true:

- the service is already broken and restoration is the task
- a config change has already been made and restart is required to apply it
- the user explicitly asked for a restart after the risks were established

Restart is forbidden when the only reason is:
- uncertainty caused by stale handoff
- lack of read-only verification
- speculative troubleshooting without evidence

## Handoff Invalidation Rule

Treat every handoff as time-sensitive and suspect.

A handoff becomes stale as soon as any of these happen:

- the service was restarted
- the unit or drop-ins changed
- the protected application changed
- the state file changed
- the watcher or flow changed

After any of those events, the next agent must re-verify live state before acting on the handoff.

## "Unknown Runtime" Rule

An agent must not say runtime state is unknown if current evidence already proves it.

Examples of sufficient proof:

- `systemctl show` exposes the live env
- startup log prints the effective config
- persisted state shows the same config family
- a real response check confirms readiness

If those agree, the correct conclusion is "known and verified", not "unknown".

## Handoff Hygiene For AI Agents

When writing handoff:

- separate facts from assumptions
- mark every fact with the source that proved it
- state the verification timestamp or relative recency
- explicitly list what was not verified
- never propose a restart as the first step unless the service is already down or broken

## Minimal Pre-Action Checklist

Before any mutation, the agent must answer:

1. What does the live host say right now?
2. What does the current startup log say right now?
3. What does the current persisted state say right now?
4. What real response check has already been run?
5. What part of the handoff is still unverified?

If any answer is missing, the agent is not ready to mutate the target.
