---
name: design-project
description: Research and resolve consequential technical projects before implementation. Use when Sean explicitly invokes $design-project for a TDD, RFC, design proposal, or substantial ambiguous ticket. Own product framing, repository research, architecture, program design, and semantic verification. Produce an evidence-grounded design handoff for a fresh writing session rather than publication prose directly.
---

# Design Project

Turn unsettled technical work into an evidence-grounded design that can be handed to a fresh writer without requiring that writer to reconstruct the investigation.

This session optimizes for correctness, completeness, and decision quality. It does not optimize the final document's prose.

Sean owns consequential product judgments. Continue autonomously when the prompt, accepted requirements, and evidence determine a clear design. Ask Sean only when a materially different product outcome or expensive-to-reverse tradeoff cannot be resolved from the supplied intent and evidence.

Read [references/tdd-template.md](references/tdd-template.md) and [references/artifact-templates.md](references/artifact-templates.md) before substantial design work.

Do not use the technical-writing skill as a continuous constraint during repository exploration or architecture reasoning. Research notes and internal design language may be optimized for efficient reasoning. Publication-quality technical writing happens later in a fresh session.

## Core separation of concerns

The workflow has four distinct jobs:

1. **Design:** establish what is true and what should be built.
2. **Writing and revision:** express the accepted design for a human reader in a fresh context, then revise it from independent findings.
3. **Prose review:** test section placement and prose quality from another fresh context.
4. **Reader review:** test whether a fresh reader can recover the design without the author's context.

This skill owns the first job and semantic verification of every candidate sent to independent review.

Do not collapse these jobs merely because one session is capable of performing all of them.

The absence of context in later sessions is deliberate. Do not compensate by passing the research transcript, subagent histories, exploratory reasoning, or other accumulated context to the writer or either reviewer.

## Choose the process depth

Classify the work before expanding the process.

### Direct plan

Use when the change is local, reversible, implementation-ready, and follows an established pattern.

Do not create a TDD or design handoff. Produce the smallest useful approach and verification contract or route the task to the implementation workflow.

### Issue design

Use when the product outcome is settled but implementation crosses a meaningful boundary, introduces a durable contract, or leaves a consequential code-shape choice.

Reuse accepted product requirements rather than redesigning them.

### Full TDD design

Use when the work is cross-service, security-sensitive, durable, migration-heavy, operationally risky, product-ambiguous, or large enough to contain several consequential boundaries.

Complexity or implementation size alone does not justify a full TDD. The deciding question is whether a misunderstanding would create expensive product, architecture, maintainability, rollout, or review rework.

## Preserve accepted working state

Treat existing issues, product briefs, ADRs, experiments, accepted review comments, and partial designs as input. Do not restart merely to impose this workflow.

Keep these categories distinguishable throughout the design:

- verified current behavior;
- accepted product requirements;
- technical requirements;
- proposed choices;
- accepted architecture invariants and design decisions;
- rejected alternatives;
- open questions; and
- implementation details.

Research workers return evidence. They do not own the design.

Do not treat an existing code path, type, route, comment, or ADR as authoritative merely because it exists. Establish whether it represents active supported behavior, historical precedent, vestigial code, or an unimplemented proposal.

## Use subagents for bounded research

Delegate read-heavy repository research when doing so keeps noisy exploration out of the design thread or allows independent questions to be investigated in parallel.

Each research track must have:

- one decision question;
- explicit scope and non-scope;
- likely authoritative evidence;
- accepted constraints it must preserve; and
- a bounded return contract.

Research workers return:

1. verified current behavior with repository references;
2. relevant constraints and invariants;
3. feasible options and tradeoffs;
4. a recommendation;
5. dependencies or conflicts with other tracks; and
6. unresolved decisions.

Do not delegate cross-track synthesis or product judgment.

A worker may perform a disposable runtime probe when empirical behavior matters. It must not implement production code.

## Establish the product contract

Before architecture, establish or link:

- the observable user or platform outcome;
- committed behavior;
- scope and non-goals;
- relevant product policy and external constraints;
- success evidence; and
- unresolved product decisions.

Challenge solution language that has been presented as a requirement.

Do not settle a product choice from technical convenience or a research worker's recommendation.

## Establish current-state evidence

Inspect the relevant code, tests, callers, history, ADRs, contracts, configuration, generated schemas, and runtime behavior in proportion to the claims the design needs to make.

Trace actual execution paths rather than reasoning primarily from names.

For consequential current-state claims, retain concrete repository anchors such as:

- file paths;
- symbols;
- schemas;
- endpoints;
- workflow names;
- tests;
- configuration keys; or
- observed runtime behavior.

A later writer should not have to rediscover why a claim is believed.

## Confirm scope with Sean

For an issue design or full TDD, stop after the bounded research needed to explain the product boundary and before choosing architecture or program design. Return this checkpoint:

```markdown
## Scope checkpoint

**Outcome:** <observable result>

**In scope:** <users, entry points, workflows, and behavior>

**Accepted limitations or UX quirks:** <behavior that may remain inconsistent, imperfect, or unsupported>

**Out of scope or deferred:** <explicit exclusions>

**Decisions needed:** <only consequential choices that remain>

**Technical consequences:** <the important complexity or simplification created by this boundary>
```

Ask Sean to accept or revise the scope before continuing. Do not produce the architecture, exact external contracts, program design, or Design Handoff in the same turn as an unaccepted scope checkpoint.

Do not infer that every related entry point must behave consistently. A deliberate limitation or UX quirk may be cheaper and better than expanding the design, but Sean must accept that tradeoff explicitly.

If later evidence changes an accepted scope boundary or reveals a material consequence that was absent from the checkpoint, reopen the scope discussion before continuing.

## Frame architecture questions

Sketch the current and proposed end-to-end flow and identify material questions involving:

- participating systems and ownership;
- sources of identity, authority, policy, and durable truth;
- data that is read, written, queued, replayed, migrated, or reconciled;
- public, internal, and durable contracts;
- security and trust boundaries;
- failure and recovery behavior;
- compatibility and deployment overlap; and
- decisions that are risky or expensive to reverse.

Research only questions whose answers could materially change the design.

Before strengthening a trust, durability, consistency, or failure-handling guarantee, identify:

1. the current guarantee;
2. the required guarantee;
3. the concrete failure or threat;
4. why the established behavior is insufficient.

Require only the guarantee the accepted scenario needs.

## Synthesize the design

Combine research into one coherent proposal. Do not concatenate worker handoffs.

For every new abstraction, state store, compatibility mechanism, service boundary, durable contract, or guarantee, identify the accepted requirement or concrete failure that justifies it. Remove or narrow machinery that cannot pass this test.

Separate architecture from program design.

Architecture owns:

- deployable systems and meaningful boundaries;
- responsibility and authority;
- important cross-system sequences;
- sources of truth;
- persistent or durable semantics;
- security and failure invariants;
- compatibility and rollout decisions; and
- consequential alternatives.

Program design owns:

- repository files and modules;
- internal types and schemas;
- endpoint details;
- helper or adapter responsibilities;
- call-stack changes;
- state-machine mechanics; and
- the code shape needed for the next implementation slices.

Prefer established repository concepts over new conceptual layers.

## Control invented ontology

During research it is acceptable to create shorthand that helps reason about the system. Do not silently promote that shorthand into the proposed architecture.

For every project-specific term introduced during design, classify it as one of:

- **Existing term:** already established in code, documentation, product language, or the technical domain.
- **Proposed durable term:** a new concept the design intentionally introduces and future engineers should use.
- **Working shorthand:** language useful for this investigation but not itself part of the design.

For an existing term, record a concrete repository or documentation anchor when useful.

For a proposed durable term, define exactly what it refers to, why the concept deserves a name, and where it will exist concretely in the system.

Working shorthand must not automatically survive into the final TDD.

Do not mistake fluency inside the research session for evidence that a term will be clear to a fresh reader.

## Design the program

Once architecture is coherent, establish enough repository-level design for the next one to three implementation slices:

- file-tree changes and responsibilities;
- call-stack or control-flow changes;
- important public, internal, and durable contracts;
- important types, fields, schemas, and method signatures;
- migration, replay, concurrency, and compatibility mechanics;
- failure and degraded behavior; and
- verification evidence.

Inspect existing callers, types, identifier formats and limits, framework conventions, generated schemas, durable context, and runtime guarantees before specifying exact contracts.

Expose choices an implementation agent might otherwise make implicitly, but do not write a disguised implementation.

## Map delivery and verification

Prefer small vertical slices that prove observable behavior or retire a named technical risk.

Each slice must identify:

- the behavior or risk it proves;
- the end-to-end path involved;
- accepted architecture it preserves;
- dependencies and non-goals; and
- evidence required to consider it complete.

Detail only the first one to three slices. Keep later work as a map until evidence makes more detailed planning useful.

## Resolve newly uncovered consequential choices with Sean

Before freezing the Design Handoff, review every unresolved decision returned by later research and every choice the proposed design added beyond the accepted scope checkpoint.

Do not silently choose when an option would materially change:

- which users, entry points, or workflows are in scope;
- public behavior or an exact external contract;
- a durable data or replay contract;
- authorization, failure, or privacy guarantees;
- migration or deployment risk; or
- work deferred to a later project.

Present the smallest decision needed, the evidence, and the meaningful consequence of each viable option. Ask Sean to decide before the handoff is frozen. Record the accepted choice in the product contract or accepted design decisions. If nothing has changed since the accepted scope checkpoint, continue without asking Sean to approve the same scope twice.

## Freeze the Design Handoff

Once the design is technically coherent, stop turning the research session into a polished TDD.

Instead produce one canonical **Design Handoff** for the fresh writer.

The handoff is a semantic source of truth, not publication prose. It may be repetitive or structurally explicit when that reduces the chance of losing meaning.

Use this structure:

```markdown
# Design Handoff: <project>

## Intended document

**Audience:** <who will read the final artifact>

**Artifact:** <TDD, issue design, RFC, etc.>

**Purpose:** <what the reader must understand or decide>

## Product contract

**Outcome:** <accepted outcome>

**In scope:**
- ...

**Non-goals:**
- ...

**Product constraints:**
- ...

## Verified current state

### F-01: <concise fact>
**Evidence:** <paths, symbols, tests, docs, runtime observation>
**Status:** active supported behavior | historical | vestigial | other

### F-02: ...

## Requirements

### R-01
<atomic product or technical requirement that every acceptable solution must satisfy>

**Reason/source:** <accepted product requirement, failure mode, external constraint, etc.>

## Accepted design decisions

### D-01: <decision or architecture invariant>
**Decision/invariant:** <concrete design choice or guarantee created by the chosen architecture>
**Why:** <rationale necessary to preserve the choice>
**Concrete anchors:** <systems, paths, modules, types, or planned locations involved>
**Depends on:** <R/F/D identifiers when useful>

## Program design

### P-01: <implementation-shape decision>
**Shape:** <files/types/call flow/contracts>
**Grounding:** <existing callers/types/framework behavior>
**Depends on:** <accepted architecture>

## Failure, compatibility, and deployment behavior

### C-01
<concrete required behavior and why it exists>

## Verification

### V-01
**Claim:** <what must be shown>
**Evidence:** <test, command, runtime probe, trace, screenshot, etc.>

## Rejected alternatives

### A-01: <alternative>
**Rejected because:** <specific reason under accepted requirements>

## Open questions

### Q-01
**Question:** ...
**Owner:** ...
**Consequence:** ...

## Terminology ledger

| Term | Status | Concrete meaning or anchor | Publication guidance |
| --- | --- | --- | --- |
| <term> | existing | <path/type/domain meaning> | use normally |
| <term> | proposed durable | <exact concept> | define before use |
| <term> | working shorthand | <what we meant internally> | rewrite concretely; do not inherit automatically |

## Publication obligations

List the semantic claims that the final document must preserve. These are not sentences the writer must copy; they are meanings that may not disappear or materially change.

### O-01
<required meaning>

**Source:** <F/R/D/P/C/V identifiers>

### O-02
...
````

Keep the handoff bounded to information the final document or semantic verifier needs. Raw exploration logs do not belong in it.

Before freezing the handoff, inspect every `R` item. Keep it as a requirement only when it describes behavior or a constraint that every acceptable solution must satisfy. If it names a selected field, type, module, call path, propagation mechanism, or combination of safeguards, move that meaning to `D`, `P`, or `C` unless the exact mechanism is itself an accepted constraint. Do not preserve a design choice as a requirement merely because the design depends on it.

## Hand off to a fresh writer

When the Design Handoff is complete, the publication draft must be created in a fresh Codex thread using the design-writer skill.

Give that thread:

* the Design Handoff;
* the governing TDD/RFC template and repository documentation conventions;
* the technical-writing skill; and
* explicitly referenced source files only when needed.

Do not give it:

* this conversation;
* the research transcript;
* subagent transcripts;
* discarded alternatives beyond those preserved in the handoff;
* exploratory reasoning; or
* accumulated repository search output.

The writer may use targeted repository reads to clarify an exact identifier or syntax, but must not perform broad design research or silently change the accepted design.

## Independent review and revision loop

After the writer produces a candidate document, perform the semantic verification below. Do not spend independent review cycles on a candidate that does not yet preserve the Design Handoff.

Once semantic verification passes, launch two fresh review threads against the same candidate version. They may run in parallel. This is review cycle 1.

Launch one thread with the technical-document-prose-reviewer skill. Give it only:

* the candidate document;
* the governing artifact template; and
* repository documentation conventions when they affect the published artifact.

Launch the other thread with the technical-document-reader skill. Give it only:

* the candidate document; and
* the reader-review instructions.

Do not give either reviewer the Design Handoff, research context, writer reasoning, previous drafts, or previous reviewer findings.

Each reviewer must complete its whole-document review and return all material findings it can identify in that pass. It must not stop after finding enough to return `REVISE`.

Return the complete set of `REVISE` findings to the existing writer thread together. The writer makes one coherent revision against the full set while preserving the Design Handoff. Do not start another review cycle after a partial or single-finding edit.

After any revision, run semantic verification on the revised candidate first. If it passes, launch new prose-review and reader-review threads against that candidate. Do not reuse reviewers that have learned the document's vocabulary or seen explanations of earlier findings.

Run at most three prose-and-reader review cycles in total. If either reviewer still reports a blocking finding in cycle 3, stop and give Sean the unresolved findings, the affected passages, and whether they appear to reflect unclear design or an unreliable review criterion. Do not launch cycle 4.

Do not treat the writer's own final pass as a substitute for either independent review. Minor stylistic preferences do not block convergence.

## Semantic verification

Before each independent review cycle, resume this original design session and verify the candidate against the accepted Design Handoff and source evidence.

This pass is semantic, not stylistic.

Check for:

* accepted claims that disappeared;
* claims whose certainty changed;
* requirements weakened or strengthened;
* a requirement that now encodes a selected implementation or belongs to a design section;
* a design decision or architecture invariant presented as an independent requirement;
* decisions whose boundary changed;
* rationale whose removal makes a decision materially easier to misunderstand;
* unsupported new technical claims;
* a working shorthand that became an architectural fact;
* an open question silently converted into a decision;
* contradictions between sections; and
* examples or exact contracts that no longer match source evidence.

Always record the result in this form, including a `PASS` result:

```markdown
## Semantic verification

**Verdict:** PASS | REVISE | DESIGN REOPENED

**Summary:** <no semantic differences found, or a concise account of what must change>

<!-- Include finding blocks only for REVISE or DESIGN REOPENED. -->
### S-01
**Type:** dropped | changed | strengthened | weakened | misclassified | unsupported | contradiction | unresolved
**Design source:** <handoff identifier>
**Document location:** <section/phrase>
**Problem:** <semantic difference>
**Required correction:** <meaning that must be restored; do not prescribe stylistic wording>
```

Do not offer prose improvements during semantic verification.

If all publication obligations and accepted decisions are preserved and no unsupported claims were introduced, return `PASS` and state that no semantic differences were found.

If the writer can repair the problem without changing the accepted design, return `REVISE` and send the findings back to the writer.

If the discrepancy exposes a missing or invalid design decision, return `DESIGN REOPENED`, update the Design Handoff after resolving it, and then send the new design state to the writer.

After any semantic correction, verify the revised candidate again before sending it to independent review. A semantic correction made after a review cycle requires a new prose and reader cycle and remains subject to the three-cycle limit.

## Convergence rule

The document is complete only when all three are true for the same candidate version:

1. a fresh prose reviewer reports `PASS`;
2. a fresh reader reports no material comprehension problem; and
3. semantic verification reports `PASS`.

Do not optimize indefinitely for stylistic preference.

The three-cycle limit is a hard cap across all prose-and-reader review cycles, not three attempts per issue class. A design reopening creates a new accepted handoff and restarts publication from a new candidate; it does not authorize silently resolving the design question or continuing an unbounded review loop.

## Publication

After convergence:

* remove temporary Working State or design-process material;
* ensure repository-local metadata and formatting are correct;
* preserve links and source references useful to future engineers;
* leave the Design Handoff as temporary working material unless repository policy says otherwise; and
* return the final TDD/RFC as the product of the workflow.

The final document should describe the accepted system, not the process that produced it.
