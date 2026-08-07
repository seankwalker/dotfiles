---
name: work-on-issue
description: Research, start, or resume a Linear issue from an independent Codex worker session in an existing task worktree; choose autonomous execution, a bounded experiment, or a human decision before producing a verified handoff.
---

# Work On Issue

Own new or existing implementation through realistic verification. Keep coordination and daily-note editing in the driver session.

## Establish the contract

1. Confirm the current Git root and branch. Do not work directly on `main` or `master`.
2. Use an issue ID supplied by the user. Otherwise extract the first case-insensitive identifier matching `<TEAM>-<number>` from the current branch name.
3. Retrieve the Linear issue with relations and read its comments. Treat the issue description, acceptance criteria, linked design material, and relevant recent comments as the contract.
4. Compare the current branch with Linear's suggested branch. A matching issue identifier is sufficient when only the slug differs; surface a material mismatch before editing.

If no issue can be resolved or this is not a task worktree, stop with a concise instruction to create/open the worktree and start a worker session there. Do not move the driver onto another worktree.

Do not change Linear state, post comments, create a PR, or merge unless the user explicitly requests it.

## Resume existing work

Before setup or editing, reconstruct the current lifecycle state:

1. Inspect repository status, commits relative to the base branch, the current diff, and existing test evidence.
2. Check the linked PR, CI, and review state when a PR already exists.
3. Use prior session context as a lead, but verify consequential claims against current repository and external state.
4. Classify the issue as not started, implementing, verifying, ready for review, in PR review, blocked, or needing a decision.
5. Continue from the earliest incomplete stage.

Preserve valid existing work. Do not reset, recreate, or redo changes merely to obtain a clean start. Rerun verification only when evidence is missing, stale, or affected by later changes. If the branch and issue disagree materially or the correct continuation is ambiguous, stop with one clear question rather than guessing.

When implementation and verification are already complete, do not create extra changes. Report the current state and the actual next action.

## Prepare the worktree

Read every applicable repository instruction file before acting. Inspect the repository and issue enough to identify the intended change, existing patterns, and relevant verification.

Perform normal setup rather than working around a fresh environment:

- Use the repository's documented bootstrap or preflight when one exists.
- If this is the company monorepo and Yarn dependencies are absent, run `yarn install` before commands that require them.
- Start required services or local infrastructure when realistic verification needs them.
- Treat missing dependencies and uninitialized services as setup work, not reasons to silently substitute static inspection, weaker tests, improvised mocks, or unrelated commands.
- If normal setup genuinely fails, diagnose it and make the verification gap prominent in the handoff.

Follow active repository-local delegation policy. Do not add orchestration simply out of habit when the personal `AGENTS.override.md` permits direct implementation.

## Choose an execution path

Before production edits, perform a short, bounded research pass. Read the issue and linked material, then inspect the relevant code, tests, history, and current state. In commentary, state a compact checkpoint:

- Intended outcome
- Relevant evidence or established pattern
- Proposed approach
- Meaningful alternative or unknown, if any
- Selected path: `Execute`, `Experiment`, or `Needs decision`

Do not pause merely to emit the checkpoint. Select the path using these rules:

1. **Execute** when the requested behavior and implementation layer are constrained by the contract and a canonical existing pattern. Continue autonomously through verification.
2. **Experiment** when correctness depends on behavior that must be learned empirically, such as model behavior, runtime behavior, performance, or deployment state. Build and run the smallest useful probe or eval, then reassess once. Continue only if the evidence resolves the approach and the remaining change is low risk; otherwise return `Needs decision` with the result and one question.
3. **Needs decision** when reasonable approaches would produce materially different product behavior or long-lived architecture. Stop before production implementation and return the recommended approach, the strongest alternative, the evidence, and one clear question. Read-only research and a small disposable probe are allowed.

Treat these as decision triggers unless the contract explicitly settles them:

- Product behavior, ownership, or rollout semantics are missing.
- More than one plausible implementation layer or repository pattern exists.
- The change affects durable replay, deployment, authentication or security, a data model, a public API, feature exposure, or release sequencing.
- A tool-specific mechanism may duplicate a shared policy or boundary.
- The issue, ADR, code, and current operational state conflict or leave a consequential assumption unresolved.

A plausible inference from code or an ADR is not settlement when another reasonable interpretation would materially change the user or product outcome.

## Implement and verify

1. Translate the issue into a small set of observable acceptance claims.
2. Follow the selected execution path without expanding scope.
3. Add or update focused tests that prove the changed behavior.
4. Run the most relevant tests, static checks, and realistic end-to-end evidence available for the change.
5. Review `git diff`, repository status, and the acceptance claims before finishing.

Evidence should fit the work: failing-before/passing-after tests for bugs, request/response evidence for APIs, screenshots or browser checks for UI, and logs or observed state transitions for asynchronous behavior. Never claim a check passed without running it.

If implementation reveals a consequential choice that the checkpoint missed, stop at the smallest useful point and return `Needs decision` using the same standard.

## Hand off external waits

Do not keep the worker occupied solely to poll CI, review, Mergefreeze, deployment, rollout, or another external gate after the bounded local work is complete.

1. Check the gate once and capture its current state and URL or other evidence.
2. State the exact re-entry condition and the first action to take when it clears.
3. Return the handoff below. Use `Ready for review` when the implementation is complete and PR, CI, or human review remains; use `Blocked` when the external outcome controls further implementation.

One bounded wait is reasonable when a result is imminent and would materially change the handoff. Do not monitor indefinitely. A later session can invoke `$work-on-issue` to reconstruct the live state and continue.

## Handoff

End every worker run with this compact shape:

```markdown
**Status:** Ready for review | Blocked | Needs decision

**Starting point:** New issue | Resumed from <lifecycle stage>

**Outcome**
<What behavior now exists, or where work stopped.>

**Changed**
- <Important change surface>

**Verified**
- `<exact command>` — pass | fail
- <Other evidence tied to an acceptance claim>

**Review attention**
- <Material decision, alternative, risk, deviation, or unverified area; for `Needs decision`, include the evidence and recommended approach>

**Waiting on**
- <External gate, current state, and re-entry condition; "Nothing" if empty>

**Next**
<The single next action: review, answer a question, fix setup, or invoke `$github:yeet`.>
```

Keep it concise, but never omit failed checks or verification gaps. Do not mark the Linear issue complete merely because code is ready for review.
