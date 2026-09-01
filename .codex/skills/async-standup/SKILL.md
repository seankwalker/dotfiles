---
name: async-standup
description: Draft a concise, ready-to-post async Slack standup from the settled Obsidian daily plan and the most recent closeout. Use when Sean asks for an async standup, morning Slack update, or team status update after planning the day.
---

# Async Standup

Draft a team-relevant snapshot of recent progress, today's intended outcomes, and any active blockers.

## Gather context

1. Use a date or daily-note path supplied by the user. Otherwise use the current date in `America/Los_Angeles` and `/Users/sean/Documents/Obsidian Vault/daily/YYYY-MM-DD.md`.
2. Read today's `Outcomes`, `Other tasks`, and `Log`.
3. Read the most recent earlier daily note's `Closeout` for completed work and carry-forward context.
4. Use relevant commitments stated in the current conversation.
5. If today's priorities are missing or materially unsettled, identify the decision instead of inventing a plan.

## Draft the update

Use this exact Slack-friendly shape:

```text
:rewind: Yesterday:
- <one or two meaningful shipped, verified, or decided outcomes>

:arrow_forward: Today:
- <one to three outcome-oriented priorities>

:octagonal_sign: Blockers:
- <active blocker, or "None">
```

Keep the complete update around 60–120 words and ready to paste without editing. Prefer plain language over internal task mechanics. Include Linear identifiers or links when they help teammates follow the work. Consolidate related tasks into an outcome rather than copying the checklist verbatim.

Use a literal ASCII hyphen followed by a space (`- `) for every bullet so Slack formats pasted updates consistently. Do not use Unicode bullet characters.

Mention stretch work only when it is likely to receive attention. Treat on-call duty or interruptions as capacity context, not as an apology. Keep `Blockers` limited to something actively preventing a listed outcome; write `- None` when there is no blocker.

Draft only. Do not post to Slack or edit the daily note unless the user explicitly asks. If the plan changes materially, rerun the skill to produce a fresh snapshot.
