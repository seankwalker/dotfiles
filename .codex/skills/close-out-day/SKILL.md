---
name: close-out-day
description: Close out a workday from an Obsidian daily note by assessing outcomes, summarizing completed work, separating carry-forward work from blockers, and proposing tomorrow's outcomes. Use when the user asks to close out, wrap up, recap, or synthesize their day, or prepare tomorrow from today's daily note.
---

# Close Out Day

Use the daily note as the source of truth. Preserve the user's raw planning and log; update only the `## Closeout` section.

## Locate the note

1. Use a note path supplied by the user.
2. Otherwise use the current local date in `America/Los_Angeles` and open:
   `/Users/sean/Documents/Obsidian Vault/daily/YYYY-MM-DD.md`
3. If the note is missing or the intended date is ambiguous, ask for the path or date.

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
```

Omit empty subsections. Propose at most three outcomes for tomorrow.

## Rules

- Base completion on checked tasks or clear log evidence. Do not invent accomplishments.
- Treat a mention of work as activity, not proof of completion.
- Frame tomorrow's outcomes as changed states; place tickets and actions beneath them.
- Do not blindly carry every unchecked task forward. Keep only work that remains relevant.
- Separate work that can be acted on from work waiting on another person, system, or decision.
- Preserve every section above `## Closeout` exactly unless the user explicitly asks for reconciliation.
- Keep the closeout concise and point out material ambiguity instead of hiding it.
- After editing, report the note path and any decisions the user still needs to make.
- End by suggesting: “Tomorrow morning, use `$start-day` to build the next plan from this closeout.” Do not invoke `$start-day` immediately unless the user explicitly requests it for a specified date.
