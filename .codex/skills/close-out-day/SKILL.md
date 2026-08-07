---
name: close-out-day
description: Close out a workday from an Obsidian daily note by reconciling every planned and captured item, assessing outcomes, reviewing unsynced dotfile changes, proposing tomorrow's outcomes, and auditing Codex sessions active that day for workflow friction.
---

# Close Out Day

Use the daily note as the source of truth. First perform the final worker sync, then reconcile the day's plan and inbox before producing the closeout.

## Locate the note

1. Use a note path supplied by the user.
2. Otherwise use the current local date in `America/Los_Angeles` and open:
   `/Users/sean/Documents/Obsidian Vault/daily/YYYY-MM-DD.md`
3. If the note is missing or the intended date is ambiguous, ask for the path or date.

## Perform the final sync

Read and follow `/Users/sean/.codex/skills/sync-work/SKILL.md` for the same date and note before producing the closeout. This reconciles independent worker progress, records meaningful final log entries, and advances the sync cursor. Do not wait for workers that are still active.

If session discovery is unavailable, continue with the existing daily note and report that the final sync was skipped.

## Reconcile the plan and inbox

Read `## Outcomes`, `## Other tasks`, and `## Captured` before writing the closeout.

- Update task checkboxes in `Outcomes` and `Other tasks` from clear evidence. Keep unfinished work unchecked.
- Account for every unchecked planned task in `Carry forward`, `Waiting`, `Tomorrow`, or `Not continuing`. Do not silently strand it in the old note.
- Treat `Captured` as an inbox, not a backlog. Process every entry into completed, a durable ticket or linked artifact, carry-forward or tomorrow, waiting, or an explicit decision to drop it.
- Check a captured entry after it is processed. If the underlying work remains, append its destination, such as `→ ALI-123`, `→ Tomorrow`, or `→ Waiting`; the checkmark means the inbox item was triaged, not that the underlying work shipped.
- When future project work has no durable ticket, put `Create Linear issue for …` in `Carry forward` or `Tomorrow`. Do not invent an issue or pretend the capture is durably tracked.

Do not finish the closeout with an unchecked `Captured` entry. If its disposition is materially ambiguous, ask the user to decide.

## Review dotfile sync state

Inspect Sean's dotfiles checkout read-only:

```sh
git --git-dir=/Users/sean/.dotfiles/.git --work-tree=/Users/sean status --short --untracked-files=no
git --git-dir=/Users/sean/.dotfiles/.git --work-tree=/Users/sean diff --stat
git --git-dir=/Users/sean/.dotfiles/.git --work-tree=/Users/sean diff --cached --stat
```

Also use the day's note and session audit to identify home-configuration files created or materially changed that day. For any such file absent from status, check whether it is untracked or ignored with `git ls-files` and `git check-ignore -v` so local-only configuration is explicit rather than silently missed.

Summarize the result under `### Dotfiles` in the closeout. List files or coherent groups that still need review and GitHub sync, and separately identify intentional local-only or ignored changes. If nothing changed, state `- Clean; nothing to sync.` Do not stage, commit, pull, or push unless the user explicitly asks.

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

### Not continuing
- <explicitly dropped or superseded commitment and brief reason>

### Tomorrow
- <proposed outcome>
  - [ ] <likely concrete step>

### Dotfiles
- <unsynced tracked changes, or clean state>
- <local-only or ignored configuration changed today, when applicable>

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
- Preserve normal completion semantics for `Outcomes` and `Other tasks`; never check an unfinished task merely because it was carried forward.
- Frame tomorrow's outcomes as changed states; place tickets and actions beneath them.
- Do not blindly carry every unchecked task forward. Keep only work that remains relevant.
- Separate work that can be acted on from work waiting on another person, system, or decision.
- Keep per-session audit findings even when no pattern recurred that day. Label a daily pattern recurring only when it appears in at least two root sessions.
- Summarize workflow evidence; never copy raw session logs or potentially sensitive command output into the note.
- Outside the final sync and the checkbox and destination reconciliation above, preserve every section above `## Closeout` exactly.
- Keep the closeout concise and point out material ambiguity instead of hiding it.
- After editing, report the note path and any decisions the user still needs to make.
- End by suggesting: “Tomorrow morning, use `$start-day` to build the next plan from this closeout.” Do not invoke `$start-day` immediately unless the user explicitly requests it for a specified date.
