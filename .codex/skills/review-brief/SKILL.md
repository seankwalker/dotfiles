---
name: review-brief
description: Explain a colleague's checked-out branch before human code review, building a mental model of its purpose, architecture, behavior, important changes, tests, and review hotspots. Use for branch walkthroughs and review preparation; concrete defects are a separate secondary output.
---

# Review Brief

Help the human understand the change well enough to review the consequential code and ask informed questions. Optimize for understanding and review leverage. The human owns approval.

## Invocation and scope

- `$review-brief`: explain the checked-out branch relative to its inferred target branch.
- `$review-brief against origin/main`: use the supplied base.
- An issue, PR, spec path, or particular commit/range may accompany the request. Treat these as ordinary language, not a required flag syntax.

Inspect without changing source, tests, commits, or the working tree. Do not fix findings, post comments, approve, push, rewrite history, or edit daily notes. Return the brief in the session; create no report files or HTML unless requested. Use existing Git and configured tools; no specific connector is required.

## Establish what is being reviewed

1. Read applicable repository and nested instructions, including active overrides, and relevant conventions or architecture guidance. Apply their substantive rules without automatically launching their separate fix, publication, or exhaustive-review workflows.
2. Follow [references/comparison.md](references/comparison.md) to resolve and pin the target, base, and merge base. Review committed branch changes by default. Name excluded local edits; do not silently include them or let them alter the code you explain.
3. Inspect the complete changed-path inventory, diff statistics, commit messages, and meaningful hunks, including deletions and renames. A truncated tool response is not the complete diff: retrieve the missing parts. Start with scope and problem context before investigating implementation details.
4. Find the originating intent in supplied context, PR/issue references, commits, and local design documents. Use configured read-only tools for relevant PR discussions, issue requirements, and CI when available. Prefer explicit references over broad searches. Missing access or a missing spec is a stated limitation, not a reason to block an otherwise useful brief.

Compare descriptions and requirements with the actual behavior. A PR description can be stale, a requirement can conflict with another constraint, and an unexplained edit may be accidental. Report material mismatches rather than choosing the most convenient account. Cite explicit rationale; label code-derived rationale as inference. Do not invent the author's motivation.

## Build the explanation

Trace each important change through its semantic dependencies. Read surrounding functions and the relevant base-version code; follow callers, consumers, schemas, configuration, persistence, and lifecycle ownership when they determine behavior. Establish that an abstraction participates in the live path before relying on it. Investigate outside the diff to answer concrete questions, not to audit the entire repository.

Organize the walkthrough by what the reviewer must understand first: problem → system role → before/after behavior → mechanisms and interactions. Use a representative input, request, state transition, or failure to make the difference concrete. Explain constraints and consequential design tradeoffs, separating documented decisions from plausible inference. Skip obvious boilerplate and file-by-file narration. Use a small table or diagram only when it reduces explanation.

When behavior depends on an external system, distinguish what the code requests, what documented platform semantics predict, and what was actually observed. In particular, do not present an expected lifecycle transition as verified merely because the configuration looks correct.

Group changes by their role:

- Core behavior: the small set of functions or hunks that changes what the system does.
- Integration/plumbing: callers, adapters, wiring, and surface changes.
- Contracts/data: API, schema, data model, migrations, and compatibility.
- Tests: new or changed behavioral evidence.
- Mechanical/supporting: generated output, release metadata, formatting, and configuration.

These are explanatory categories, not safety ratings. Configuration, imports, generated artifacts, and lockfiles can change behavior. Check their semantics before calling them mechanical or noise. Identify the few files/hunks carrying most of the semantic change; group repetitive supporting files instead of listing all of them.

## Choose review hotspots; qualify findings separately

Prioritize a few consequential places for human inspection. Each hotspot names a specific location, the changed behavior or invariant, and what the reviewer should confirm. Consider boundaries, compatibility, failure paths, state/concurrency/lifecycle, permissions, persistence/migrations, contracts, and assumptions in callers only where the diff gives a concrete reason. A checklist of generic risks is not a brief.

Keep open design or product questions distinct from defects. Do not turn an investigated, disproven concern into a hotspot just to retain it. If an important uncertainty remains, say what evidence or author answer would resolve it.

A finding needs a higher bar:

- The reviewed change introduces or worsens a discrete, consequential problem.
- A reachable scenario or call path demonstrates why the behavior is likely wrong.
- Surrounding code, callers, relevant tests, and possible compensating behavior have been checked.
- Evidence establishes the expected behavior; a stylistic preference or unverified interpretation does not.

For each qualifying finding, give impact/severity, the smallest relevant changed location, trigger, expected versus actual behavior, and supporting evidence. Use repository severity conventions if present. Label reproductions separately from conclusions established by code inspection. Do not report pre-existing defects as introduced findings. Keep confirmed open findings visible; avoid diluting them into questions. When none qualify, say "No concrete findings established" without implying approval or an exhaustive audit.

Keep findings visibly separate from review focus even in a compact brief. A demonstrated contradiction in operational instructions can qualify when this change makes the guidance wrong and consequential; investigate it under the same bar. If a discrepancy remains an open question instead, explain what is unresolved. Do not narrow a no-findings statement to runtime code while leaving an established actionable problem elsewhere unclassified.

## Interpret tests and validation

Read relevant assertions and fixtures, not just test names. Explain what behavior they exercise, what the new/changed cases establish, and material gaps connected to this change. Compare those claims with the issue/spec and the actual implementation. Passing tests may encode an incorrect expectation.

Run focused existing checks when practical and permitted by local instructions. Keep experiments disposable and outside the working tree; do not update snapshots, install dependencies, provision services, or change the colleague's branch just to complete the brief. If validation needs substantial setup, state the limitation and the useful next command. A targeted baseline-versus-target repro can strengthen a finding when feasible.

Distinguish tests inspected, checks you ran (exact command, result, revision), and author/CI-reported results (source and revision). Never present another revision's green checks or a test reading as validation of this target. Report failed checks and relevant environment limitations without silently declaring them unrelated.

## Present the brief

Lead with the change, then give the evidence in conceptual order. Suggested shape:

1. **Purpose and scope:** concise summary, problem, linked intent context, reviewed head/base/merge-base and selection reason, material exclusions or uncertainty.
2. **How it works and why:** system context, before/after walkthrough, key interactions, constraints, and explicit versus inferred rationale.
3. **What matters in the diff:** compact grouped map with the most important files/functions/hunks first.
4. **Review focus:** a few concrete inspection targets and unresolved questions, ordered by consequence.
5. **Findings:** substantiated defects separately, or the short no-findings statement.
6. **Tests and evidence:** behavior covered, results and their provenance, meaningful gaps.
7. **Reviewer takeaway:** end with 3–6 things to understand before approval, the precise places to inspect, and useful questions for the author. Use fewer for a tiny change; do not repeat the whole report.

Adapt this shape to the change. For a small change with one behavior, aim for roughly 250–400 words, combining sections where useful while keeping findings distinct. Exceed that when consequential interactions or findings need the space. For a larger change, organize by subsystem or behavior and deepen the important interactions. Do not fill empty categories. Explain each mechanism once; if a before/after table conveys it, prose should add rationale rather than repeat it. Summarize secondary validation details without hiding failures or uncertainty. Prefer useful code links (path, symbol, and line at the reviewed revision) over diff dumps. State material inspection limits. End with a short reading route that attaches the important decisions or author questions to specific code locations, not a second summary or an approve/reject verdict.
