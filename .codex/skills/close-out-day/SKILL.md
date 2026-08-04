---
name: close-out-day
description: Close out a workday from an Obsidian daily note by assessing outcomes, summarizing completed work, separating carry-forward work from blockers, proposing tomorrow's outcomes, and auditing Codex sessions active that day for workflow friction. Use when the user asks to close out, wrap up, recap, or synthesize their day, audit today's Codex work, or prepare tomorrow from today's daily note.
---

# Close Out Day

Use the daily note as the source of truth. Preserve the user's raw planning and log; update only the `## Closeout` section.

## Locate the note

1. Use a note path supplied by the user.
2. Otherwise use the current local date in `America/Los_Angeles` and open:
   `/Users/sean/Documents/Obsidian Vault/daily/YYYY-MM-DD.md`
3. If the note is missing or the intended date is ambiguous, ask for the path or date.

## Audit Codex workflow friction

Capture a cutoff before starting the audit, then discover top-level sessions active during the note's local date:

```sh
cutoff_epoch="$(date +%s)"
~/.codex/skills/close-out-day/scripts/list-active-sessions.sh YYYY-MM-DD "$cutoff_epoch"
```

The helper returns the UTC audit window and each root session. Descendant sessions are implementation evidence within their root workflow, not separate work sessions.

For each root session, launch one audit subagent. Run independent audits in parallel up to the available concurrency and queue the rest. Give each auditor the root ID and UTC window, and have it start with:

```sh
~/.codex/skills/close-out-day/scripts/session-activity.sh <root-id> <start-utc> <cutoff-utc>
```

Tell each auditor to:

- inspect only the returned time window, including active descendants;
- pipe the compact activity summary through targeted `jq` or `rg` queries instead of printing the entire object, then inspect raw rollout files only to establish evidence;
- report the task outcome and each material friction episode with symptom, cause, impact, and recovery;
- distinguish avoidable friction from normal implementation, external failures, and justified waiting;
- report explicitly when no material friction occurred;
- propose at most two concrete improvements.

The cutoff prevents the audit from recursively analyzing its own subagents. If session discovery is unavailable, complete the note closeout and report that the workflow audit was skipped.

## Produce the closeout

Read the entire note, then replace the contents beneath `## Closeout` with:

```markdown
### Outcome status
- **<outcome>** — Achieved | Partial | Not started
  - <brief evidence or remaining gap>

### Completed
- <meaningful accomplishment>

### Carry forward
- [ ] <unfinished, still-actionable work>

### Waiting
- <blocker, dependency, or promised follow-up>

### Tomorrow
- <proposed outcome>
  - [ ] <likely concrete step>

### Codex workflow audit
- **Sessions audited:** <count>
- **Recurring friction:** <pattern seen in at least two root sessions, or none>
- **Other observations:** <material one-off finding or explicit no-friction result>
- **Candidate improvement:** <smallest change worth trying>
```

Omit empty subsections. Propose at most three outcomes for tomorrow.

## Rules

- Base completion on checked tasks or clear log evidence. Do not invent accomplishments.
- Treat a mention of work as activity, not proof of completion.
- Frame tomorrow's outcomes as changed states; place tickets and actions beneath them.
- Do not blindly carry every unchecked task forward. Keep only work that remains relevant.
- Separate work that can be acted on from work waiting on another person, system, or decision.
- Keep per-session audit findings even when no pattern recurred that day. Label a daily pattern recurring only when it appears in at least two root sessions.
- Summarize workflow evidence; never copy raw session logs or potentially sensitive command output into the note.
- Preserve every section above `## Closeout` exactly unless the user explicitly asks for reconciliation.
- Keep the closeout concise and point out material ambiguity instead of hiding it.
- After editing, report the note path and any decisions the user still needs to make.
- End by suggesting: “Tomorrow morning, use `$start-day` to build the next plan from this closeout.” Do not invoke `$start-day` immediately unless the user explicitly requests it for a specified date.
