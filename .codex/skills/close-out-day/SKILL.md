---
name: close-out-day
description: Close out a workday by first preserving Sean's independent reflection, then reconciling the Obsidian daily note, worker evidence, commitments, dotfile state, and Codex workflow. Use when Sean asks to close out or reflect on the workday.
---

# Close Out Day

Preserve Sean's account of the day before generating a machine synthesis. Then use the daily note and worker evidence to challenge and complete that account without replacing it.

## Locate the note

1. Use a note path supplied by the user.
2. Otherwise use the current local date in `America/Los_Angeles` and open:
   `/Users/sean/Documents/Obsidian Vault/daily/YYYY-MM-DD.md`
3. If the note is missing or the intended date is ambiguous, ask for the path or date.

## Require Sean's reflection

Before performing the final sync or summarizing the day, require a substantive `## Reflection` in the daily note or a reflection supplied by Sean in the current conversation. It must answer:

- What did I actually accomplish?
- What was the most important judgment or decision I made?
- Where did I fail to act according to my intentions?
- What do I currently believe matters most tomorrow?

If it is missing, stop and ask Sean to write it. Do not propose answers or summarize the day first. If Sean supplies it in the conversation, record it faithfully under `## Reflection` immediately before `## Closeout`, making only formatting changes. Preserve the reflection exactly after it is recorded.

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
- note any consequential priority, product, or architecture judgment that Codex made or obscured instead of surfacing to Sean;
- report explicitly when no material friction occurred;
- propose at most two concrete improvements.

The cutoff prevents the audit from recursively analyzing its own subagents. If session discovery is unavailable, complete the note closeout and report that the workflow audit was skipped.

## Produce the closeout

Read the entire note, then replace the contents beneath `## Closeout` with:

```markdown
### Ownership check
- <where Sean's reflection and the evidence agree>
- <material discrepancy, rationalization, overlooked progress, or displaced judgment>

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
- **Judgment ownership:** <where Codex increased leverage appropriately or displaced judgment Sean should have exercised>
- **Candidate improvement:** <smallest change worth trying>
```

Omit empty subsections. Propose at most three outcomes for tomorrow.

## Rules

- Base completion on checked tasks or clear log evidence. Do not invent accomplishments.
- Compare Sean's reflection with the plan, log, worker evidence, and commitments. Highlight discrepancies, rationalizations, and unrecognized progress concisely.
- Do not overwrite Sean's interpretation. Preserve both accounts when they disagree.
- Treat a mention of work as activity, not proof of completion.
- Preserve normal completion semantics for `Outcomes` and `Other tasks`; never check an unfinished task merely because it was carried forward.
- Start tomorrow's proposed outcomes from what Sean says matters most, then challenge it explicitly when the evidence indicates a materially stronger priority. Frame outcomes as changed states and place tickets and actions beneath them.
- Do not blindly carry every unchecked task forward. Keep only work that remains relevant.
- Separate work that can be acted on from work waiting on another person, system, or decision.
- Keep per-session audit findings even when no pattern recurred that day. Label a daily pattern recurring only when it appears in at least two root sessions.
- Summarize workflow evidence; never copy raw session logs or potentially sensitive command output into the note.
- Outside the final sync and the checkbox and destination reconciliation above, preserve every section above `## Closeout` exactly, especially `## Morning assessment` and `## Reflection`.
- Keep the closeout concise and point out material ambiguity instead of hiding it.
- After editing, report the note path and any decisions the user still needs to make.
- End by suggesting: “Tomorrow morning, use `$start-day` to build the next plan from this closeout.” Do not invoke `$start-day` immediately unless the user explicitly requests it for a specified date.
