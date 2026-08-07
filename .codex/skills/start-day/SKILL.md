---
name: start-day
description: Build a focused workday plan from recent Obsidian daily notes by reviewing the most recent closeout, preserving today's commitments, choosing one to three outcomes, and placing granular tasks beneath them.
---

# Start Day

Build a focused plan in today's daily note. Treat outcomes as desired state changes and tasks as the concrete work expected to produce them.

## Locate the notes

1. Use a date or note path supplied by the user.
2. Otherwise use the current date in `America/Los_Angeles` and this vault:
   `/Users/sean/Documents/Obsidian Vault`
3. Use `daily/YYYY-MM-DD.md` for the target day.
4. Read the most recent earlier daily note, preferring the previous calendar day. Read its full plan and `Captured` inbox as a safety check, then focus on its `## Closeout` section.
5. If today's note does not exist, create it from `templates/daily.md`. Never overwrite an existing note.

## Build the plan

Read:

- The prior closeout, especially carry-forward work, waiting items, and proposed outcomes.
- Any unchecked prior `Captured` entry or planned task not accounted for by the prior closeout.
- Today's existing outcomes, tasks, and captured commitments.
- Relevant commitments stated by the user in the current conversation.

Then update today's note:

1. Set one to three outcomes under `## Outcomes`.
2. Put granular Linear issues and concrete actions beneath the outcome they support.
3. Keep standalone obligations under `## Other tasks`.
4. Preserve `## Log`, `## Captured`, and `## Closeout` exactly.

Use this shape:

```markdown
## Outcomes

### <desired state>

- [ ] <Linear issue or concrete action>
- [ ] <verification, merge, or follow-up step>

## Other tasks

- [ ] <standalone obligation>
```

## Rules

- Preserve existing commitments unless the user explicitly removes or deprioritizes them.
- Do not blindly carry forward every unfinished task. Carry work that remains relevant to today's outcomes or obligations.
- Do not treat waiting work as actionable unless a follow-up is due today.
- Keep existing Linear links and issue identifiers intact. Do not invent issue identifiers or commitments.
- Prefer outcome wording such as “Agent introspection M2 is code-complete” over “Work on agent introspection tickets.”
- Keep tasks granular even when the outcome is ambitious.
- Deduplicate tasks carried from the prior closeout and tasks already present today.
- Treat an unchecked prior `Captured` entry as an incomplete closeout. Preserve it explicitly in today's `Other tasks` until its disposition is decided; never silently omit it.
- Likewise preserve any unchecked prior outcome or standalone task that is not clearly represented in `Carry forward`, `Waiting`, `Tomorrow`, or `Not continuing`. Do not revive items the closeout explicitly dropped or superseded.
- If a missing priority would materially change the plan, identify it briefly instead of guessing.
- Edit the note directly unless the user asks only for suggestions.
- After editing, report the note path, chosen outcomes, and any unresolved priority decision.
