---
name: work-on-issue
description: Research, start, or resume a Linear issue from an independent Codex worker session in an existing task worktree; execute implementation-ready work, run a bounded experiment, or route substantial design through $design-project before producing a verified handoff.
---

# Work On Issue

Own new or existing implementation through realistic verification. Keep coordination, design acceptance, prioritization, and daily-note editing with Sean and the driver session.

## Establish the contract

1. Confirm the current Git root and branch. Do not work directly on `main` or `master`.
2. Use an issue ID supplied by the user. Otherwise extract the first case-insensitive identifier matching `<TEAM>-<number>` from the current branch name.
3. Retrieve the Linear issue with relations and read its comments. Use the issue description, acceptance criteria, linked design material, and relevant recent comments to reconstruct the contract; do not treat a draft or proposed artifact as accepted merely because it is linked.
4. Compare the current branch with Linear's suggested branch. A matching issue identifier is sufficient when only the slug differs; surface a material mismatch before editing.

If no issue can be resolved or this is not a task worktree, stop with a concise instruction to create/open the worktree and start a worker session there. Do not move the driver onto another worktree.

Do not change Linear state, post comments, create a PR, or merge unless the user explicitly requests it.

## Resume existing work

Before setup or editing, reconstruct the current lifecycle state:

1. Inspect repository status, commits relative to the base branch, the current diff, and existing test evidence.
2. Check the linked PR, CI, and review state when a PR already exists.
3. Use prior session context as a lead, but verify consequential claims against current repository and external state.
4. Classify the issue as not started, researching, needing design, implementing, verifying, ready for local review, addressing local review, in PR review, blocked, or needing a decision.
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

## Resolve the design state

Before deciding to implement, inspect linked TDDs, RFCs, ADRs, issue plans, and review comments. Determine whether the issue:

- needs no design artifact because it is local, reversible, and follows an established pattern;
- has an accepted issue design or full TDD whose next slice is implementation-ready; or
- still requires architecture or program-design review.

An issue description can settle product requirements without settling technical design. Conversely, implementation size alone does not require a TDD. The question is whether the worker would otherwise make a consequential product, architecture, maintainability, rollout, or code-shape choice implicitly.

An ADR alone does not satisfy work that requires a full TDD. When both artifacts are warranted, require an accepted TDD architecture that predates or explicitly supersedes the ADR; otherwise return `Needs design` and use the ADR only as input to validate.

Treat an accepted design as the implementation contract. Preserve its decisions and stop if repository or runtime evidence falsifies an assumption. Do not silently redesign while implementing.

## Choose an execution path

Before production edits, perform a short, bounded research pass. Read the issue and linked material, then inspect the relevant code, tests, history, and current state. In commentary, state a compact checkpoint:

- Intended outcome
- Relevant evidence or established pattern
- Proposed approach
- Meaningful alternative or unknown, if any
- Design depth: `No artifact`, `Accepted issue design`, `Accepted full TDD`, `Issue design needed`, or `Full TDD needed`
- Selected path: `Execute`, `Experiment`, `Needs design`, or `Needs decision`

Do not pause merely to emit the checkpoint. Select the path using these rules:

1. **Execute** when the requested behavior, implementation layer, and important code shape are constrained by the issue, an accepted design, and a canonical existing pattern. Continue through verification without expanding scope.
2. **Experiment** when correctness depends on behavior that must be learned empirically, such as model behavior, runtime behavior, performance, or deployment state. Build and run the smallest useful disposable probe, then reassess once. Continue only when the evidence resolves the approach and no design review is needed.
3. **Needs design** when the product outcome is settled but implementation would otherwise make a consequential architecture or program-design choice implicitly. Stop before production edits. Return the research evidence, the decisions the design must expose, a recommended depth, and the strongest alternative. Recommend `$design-project` in the driver session: use an issue design for a substantial ticket and a full TDD for cross-cutting project work.
4. **Needs decision** when reasonable approaches would produce materially different product behavior or an unresolved choice blocks useful design. Stop before production implementation and return the recommendation, strongest alternative, evidence, and one clear question.

Treat these as decision triggers unless the contract explicitly settles them:

- Product behavior, ownership, or rollout semantics are missing.
- More than one plausible implementation layer or repository pattern exists.
- The change affects durable replay, deployment, authentication or security, a data model, a public API, feature exposure, or release sequencing.
- A tool-specific mechanism may duplicate a shared policy or boundary.
- The issue, ADR, code, and current operational state conflict or leave a consequential assumption unresolved.
- The change would establish a new orchestration path, ownership boundary, concurrency model, compatibility contract, or non-obvious internal abstraction.
- The likely implementation is large enough that Sean could not cheaply recover the design by reviewing one coherent diff.

A plausible inference from code or an ADR is not settlement when another reasonable interpretation would materially change the user or product outcome.

For an issue with accepted product requirements, do not demand a new product brief merely because technical design is required. Architecture, Program Design, Verification, and vertical Milestones are usually the useful sections. Follow the TDD depth rules in `$design-project`.

## Implement and verify

1. Translate the issue and accepted design into a small set of observable acceptance claims.
2. Implement only the accepted slice or bounded issue scope.
3. Preserve the documented architecture and program design. Surface necessary deviations before they spread through the diff.
4. Add or update focused tests that prove the changed behavior.
5. Run the most relevant tests, static checks, and realistic end-to-end evidence available for the change.
6. Review `git diff`, repository status, acceptance claims, and design conformance before finishing.

Evidence should fit the work: failing-before/passing-after tests for bugs, request/response evidence for APIs, screenshots or browser checks for UI, and logs or observed state transitions for asynchronous behavior. Never claim a check passed without running it.

If implementation reveals a consequential choice or falsifies the accepted design, stop at the smallest coherent point and return `Needs design` or `Needs decision` using the same standard. Do not patch around it locally.

## Hand off for local review

After implementation and verification, return `Ready for review`. This means the complete branch diff is ready for Sean to inspect locally in Zed with `git: diff against main`; it does not mean the code is approved or ready to publish.

Before handing off, review the complete diff against the base branch yourself and make the handoff identify any design deviation, surprising code path, risk, or verification gap. Do not replace Sean's review with an agent review or claim approval on his behalf.

When Sean returns local review findings, resume the same issue and treat the findings as the current review contract. Address them without discarding valid work, rerun verification affected by the changes, review the complete diff again, and return another `Ready for review` handoff. Surface a finding that conflicts with the accepted design or introduces a consequential choice instead of silently choosing an interpretation.

Do not commit, push, or create a PR from `Ready for review`. Those actions require Sean to accept the local diff and explicitly request the publication step.

## Hand off external waits

Do not keep the worker occupied solely to poll CI, review, Mergefreeze, deployment, rollout, or another external gate after the bounded local work is complete.

1. Check the gate once and capture its current state and URL or other evidence.
2. State the exact re-entry condition and the first action to take when it clears.
3. Return the handoff below. Use `Ready for review` when the implementation is complete and PR, CI, or human review remains; use `Blocked` when the external outcome controls further implementation.

One bounded wait is reasonable when a result is imminent and would materially change the handoff. Do not monitor indefinitely. A later session can invoke `$work-on-issue` to reconstruct the live state and continue.

## Handoff

End every worker run with this compact shape:

```markdown
**Status:** Ready for review | Blocked | Needs design | Needs decision

**Starting point:** New issue | Resumed from <lifecycle stage>

**Outcome**
<What behavior now exists, or where work stopped.>

**Changed**
- <Important change surface>

**Verified**
- `<exact command>` — pass | fail
- <Other evidence tied to an acceptance claim>

**Review attention**
- <Material design decision, conformance concern, alternative, risk, deviation, or unverified area; for `Needs design` or `Needs decision`, include the evidence and recommendation>

**Waiting on**
- <External gate, current state, and re-entry condition; "Nothing" if empty>

**Next**
<The single next action. For `Ready for review`, open Zed's `git: diff against main` view. Name `$github:yeet` only after Sean has explicitly accepted the local diff.>
```

Keep it concise, but never omit failed checks or verification gaps. Do not mark the Linear issue complete merely because code is ready for review.
