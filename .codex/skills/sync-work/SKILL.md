---
name: sync-work
description: On explicit request, reconcile progress from independent Codex worker sessions into today's Obsidian daily note and return a factual status ledger without reprioritizing the day.
---

# Sync Work

Provide a pull-based factual ledger when Sean wants to reconcile independent work. This is a status tool, not the control loop for the day. It does not choose priorities, launch work, infer what Sean should do next, or replace direct review of a design, diff, or running system.

Keep the driver session responsive. Read compact deltas from independent top-level sessions; do not spawn subagents or wait for active workers. Run only on explicit invocation or as the documented final step of `$close-out-day`.

## Locate today's note

Use a date or note path supplied by the user. Otherwise use the current date in `America/Los_Angeles` and open:

`/Users/sean/Documents/Obsidian Vault/daily/YYYY-MM-DD.md`

If the note does not exist, stop and suggest `$start-day`. The driver owns this note; worker sessions must not edit it.

## Collect session deltas

Capture a cutoff before reading sessions:

```sh
cutoff_epoch="$(date +%s)"
~/.codex/skills/sync-work/scripts/session-deltas.sh YYYY-MM-DD "$cutoff_epoch"
```

The helper prefers the durable Orgloop driver inbox and falls back to Codex SQLite when the
local daemon is unavailable. An Orgloop drain is staged under the sync-work state directory;
`record-sync.sh` acknowledges it only after note reconciliation succeeds, so a failed edit can
retry the same batch without draining twice.

The helper:

- starts at the previous successful sync, or local midnight on the first run;
- excludes the current driver and its descendants;
- returns only independent root sessions with new activity;
- clips messages to keep the sync cheap;
- reports lifecycle state without interrupting or waiting for a session.

The Orgloop path currently reports completed turns. The SQLite fallback can also expose active
sessions. Treat an empty successful Orgloop batch as authoritative; do not scan SQLite merely to
fill it. Set `SYNC_WORK_SOURCE=sqlite` only for explicit diagnostics.

Inspect the returned messages and, only when useful, run read-only checks such as `git status --short` in a session's `cwd`. Do not dump full rollout files or perform the deeper friction audit owned by `$close-out-day`.

Classify each session as one of:

- **Active**: the worker is still running or has not produced a handoff.
- **Ready for review**: implementation and relevant verification are complete, but human review, PR, CI, or merge remains.
- **Blocked / needs decision**: progress requires input or an external dependency.
- **Complete**: the intended lifecycle is actually complete, normally including merge when the daily task represents an issue rather than just implementation.
- **Unclear**: the session became idle without enough evidence. State what must be inspected.

Treat worker claims as evidence, not certainty. Prefer explicit commands/results, PR state, and repository state over confident prose.

The ledger reports work state, not importance. Do not convert the number of active or ready items into a recommendation about what Sean should prioritize.

## Reconcile the daily note

Update the note conservatively:

1. Append short, timestamped `## Log` entries for meaningful changes: work launched, ready for review, blocked, merged, reprioritized, or a decision made.
2. Check a task only when its wording and the evidence agree that it is complete. Do not check a Linear issue merely because implementation is ready for review.
3. Add a worker-reported follow-up, decision, or blocker under `## Captured` only when it is actionable, not already present, and does not invent or reprioritize work beyond the handoff.
4. Preserve the outcome structure and every `## Closeout` entry.

Do not rewrite the day's outcomes, reorder tasks, create a new batch, or interpret routine worker activity as a change of plan. Sean makes those calls after reading the ledger.

Use the relevant event time converted to `America/Los_Angeles` and the existing log form:

```markdown
- HH:mm — <brief event>
```

Do not add entries for routine progress or repeat a state already recorded in the note.

After the note update succeeds, advance the cursor with the exact captured cutoff:

```sh
~/.codex/skills/sync-work/scripts/record-sync.sh YYYY-MM-DD "$cutoff_epoch"
```

If note editing fails, do not advance the cursor. If no material change occurred, leave the note unchanged but still advance it.

## Report

Return a compact ledger grouped by Active, Ready for review, Blocked, Complete, and Unclear; omit empty groups. Report the note path when it changed. End with a decision only when a worker is explicitly blocked on one; otherwise stop after the factual ledger.
