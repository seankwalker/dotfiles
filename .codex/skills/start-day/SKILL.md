---
name: start-day
description: Challenge Sean's independent morning assessment against recent Obsidian notes and available commitments, then build a focused plan with one explicit must-win outcome. Use when Sean asks to plan or start the workday.
---

# Start Day

Build a focused plan from Sean's judgment about the day. Act as an adversarial planning partner, not the source of priorities.

## Locate the notes

1. Use a date or note path supplied by the user.
2. Otherwise use the current date in `America/Los_Angeles` and this vault:
   `/Users/sean/Documents/Obsidian Vault`
3. Use `daily/YYYY-MM-DD.md` for the target day.
4. Read the most recent earlier daily note, preferring the previous calendar day. Read its full plan and `Captured` inbox as a safety check, then focus on its `## Closeout` section.
5. If today's note does not exist, create it from `templates/daily.md`. Never overwrite an existing note.

## Require Sean's assessment

Before proposing or refining priorities, require a substantive `## Morning assessment` in today's note or an assessment supplied by Sean in the current conversation. It must state:

- where the important work stands;
- what matters most today;
- why it matters; and
- Sean's proposed must-win outcome.

If it is missing, stop and ask Sean to write it. Do not suggest priorities or draft the assessment first. If Sean supplies it in the conversation, record it faithfully under `## Morning assessment`, making only formatting changes. Preserve an existing assessment exactly.

## Challenge the assessment

Compare Sean's assessment with:

- the prior closeout, especially carry-forward work, waiting items, and proposed outcomes;
- any unchecked prior `Captured` entry or planned task not accounted for by the prior closeout;
- today's existing outcomes, tasks, captured commitments, and log;
- relevant commitments stated in the current conversation; and
- available evidence about deadlines, dependencies, or current Linear state when it could change the plan.

Test for neglected higher-value work, weak assumptions, unnecessary scope, avoidance of a difficult decision, and activity that does not advance the intended outcome. State material disagreements explicitly. If resolving one requires Sean's judgment, ask for the decision before editing the plan. Do not silently replace his priorities.

## Build the plan

After the assessment and any consequential disagreement are settled, update today's note:

1. Set one to three outcomes under `## Outcomes`, with exactly one marked `Must-win`.
2. Put granular Linear issues and concrete actions beneath the outcome they support.
3. Keep standalone obligations under `## Other tasks`.
4. Preserve `## Morning assessment`, `## Log`, `## Captured`, `## Reflection`, and `## Closeout` exactly.

Use this shape:

```markdown
## Outcomes

### Must-win: <desired state>

- [ ] <Linear issue or concrete action>
- [ ] <verification, merge, or follow-up step>

### <another desired state>

- [ ] <concrete action>

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
- Keep Sean's proposed must-win unless he changes it after the challenge. Do not promote another outcome implicitly.
- Treat an unchecked prior `Captured` entry as an incomplete closeout. Preserve it explicitly in today's `Other tasks` until its disposition is decided; never silently omit it.
- Likewise preserve any unchecked prior outcome or standalone task that is not clearly represented in `Carry forward`, `Waiting`, `Tomorrow`, or `Not continuing`. Do not revive items the closeout explicitly dropped or superseded.
- If a missing priority would materially change the plan, ask Sean instead of guessing.
- Edit the note directly unless the user asks only for suggestions.
- After editing, report the note path, the must-win outcome, other chosen outcomes, and any challenge Sean explicitly accepted or rejected.
