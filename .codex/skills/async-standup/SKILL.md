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

Use this exact plain-text shape (the fence below illustrates the template; do not include a code fence in the response):

```text
:rewind: <One or two meaningful shipped, verified, or decided outcomes, written as sentences separated by periods.>

:arrow_forward: <One to three outcome-oriented priorities, written as sentences separated by periods.>

:octagonal_sign: <Active blocker, or "None.">
```

Keep the complete update around 60–120 words and ready to paste without editing. Prefer plain language over internal task mechanics. Include Linear identifiers or links when they help teammates follow the work. Consolidate related tasks into an outcome rather than copying the checklist verbatim.

Return only the standup in the final response: no preamble, code fence, blockquote, bullets, or closing explanation. Write one paragraph per section, starting with its emoji shortcode followed by the content on the same line. Use only the emojis as labels; omit “Yesterday:”, “Today:”, and “Blockers:”. Separate items with periods, not bullets or line breaks. Start each paragraph at column zero and leave one blank line between sections.

In terminal Codex, Sean can use `/copy` (or `Ctrl+O`) after the response completes instead of selecting terminal-rendered text, which can include display markers and indentation. Keep any copying instructions in commentary so they do not contaminate the copied final response. Do not change terminal settings. If clean copying is unavailable in another client, offer a UTF-8 `.txt` file containing only the draft.

Mention stretch work only when it is likely to receive attention. Treat on-call duty or interruptions as capacity context, not as an apology. Keep the `:octagonal_sign:` section limited to something actively preventing a listed outcome; write `None.` when there is no blocker.

Draft only. Do not post to Slack or edit the daily note unless the user explicitly asks. If the plan changes materially, rerun the skill to produce a fresh snapshot.
