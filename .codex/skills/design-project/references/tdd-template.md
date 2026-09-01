# Technical Design Document Standard

Use this standard for design proposals that must make consequential technical choices visible before implementation. A TDD is a decision and review artifact, not a transcript of the research that produced it and not a promise to fill every section.

When a project warrants both a TDD and an ADR, the TDD comes first and remains the design workspace until its architecture is accepted. The ADR is then written or updated to record that accepted decision. A proposed ADR must not serve as the implementation contract or substitute for the TDD investigation.

The reader should be able to answer four questions quickly:

1. What outcome and constraints are already settled?
2. How will the system work across its important boundaries?
3. What shape will the code take in the next implementation slice?
4. How will reviewers know the result is correct, operable, and safe to release?

## Choose the artifact depth

Use the smallest artifact that exposes the decisions a human should make before code exists.

| Work | Required artifact | Sections |
| --- | --- | --- |
| Small, local, reversible issue with an established pattern | No TDD. Use the `$work-on-issue` research checkpoint and acceptance claims. | Outcome, proposed approach, verification. |
| Substantial issue with a settled product outcome | Issue design proposal. Do not rewrite product requirements already accepted in the issue. | Objective, Context, relevant Technical Requirements, Architecture when a boundary or durable contract changes, Program Design, Verification, and one or more vertical Milestones when the work should be reviewed in slices. |
| Project or cross-cutting change | Full TDD. | Metadata, Objective, Context, Requirements, Architecture, Program Design, Verification, Deployment and Rollout, Observability, Milestones, Resources. |
| Large refactor, migration, or infrastructure change with no new product behavior | Full technical TDD with the accepted motivation linked. Product requirements may be omitted. | Objective, Context, Technical Requirements, Architecture, Program Design, Verification, Deployment and Rollout, Observability when operational behavior changes, Milestones, Resources. |

Security boundaries, durable state, cross-service contracts, public APIs, migrations, compatibility, deployment ordering, and failure recovery normally require at least an issue design proposal. Several coupled boundaries or several independently reviewable releases usually require a full TDD.

Do not create a TDD merely because the implementation is long. Create one when misunderstanding the outcome, boundaries, code shape, or delivery sequence would be expensive.

## Canonical issue design template

Use this for a substantial ticket whose product behavior is already settled. Delete optional sections that do not apply.

````markdown
# <ISSUE-ID>: <change> design

**Issue:** <link>

**Status:** Draft | In Review | Accepted | Superseded

**Reviewer:** <Sean and any responsible code owner>

## Working State

<Temporary while drafting: current pass, accepted-through gate, blockers, reopening conditions, and later-pass review queue. Remove before publication.>

## Objective

<The accepted outcome in one short paragraph. Link the issue rather than rewriting its product requirements.>

## Context

<Only verified current behavior, prior decisions, and constraints needed to judge this design.>

## Technical Requirements

- <Testable invariant or constraint every acceptable implementation must satisfy.>

## Architecture

<Include only when the ticket changes a system boundary, source of truth, durable or cross-system contract, trust model, failure boundary, compatibility rule, or deployment sequence. State the decision, ownership, important sequence, strongest alternative, and open questions.>

## Program Design

### Contracts and types

<Important endpoint, event, schema, type, or method signatures grounded in the existing callers, types, framework conventions, identifiers, limits, and generated external schemas they must extend.>

### Code layout

```text
<small file-tree diff with one-line responsibilities>
```

### Control flow

```text
<small call-stack or state-flow tree>
```

### Failure and compatibility behavior

<Only cases that influence the code shape or review.>

## Verification

| Acceptance claim or boundary | Required evidence |
| --- | --- |
| <claim> | <test, command, probe, screenshot, trace, or observed transition> |

## Milestones

<Omit for one coherent implementation. Otherwise list small vertical slices and evidence-based exit conditions.>

## Open Questions

- <Question — owner — consequence if unresolved; omit when none remain.>
````

## Writing rules

- Write for engineers who know the domain but did not participate in the research.
- State the proposed design directly. Keep verified current behavior, requirements, decisions, rejected alternatives, and open questions distinguishable.
- Put the point before supporting detail. Explain a component's role before naming internal types or files.
- Include rationale only when omitting it could lead a future engineer to reverse an important choice.
- Prefer diagrams, contract examples, file-tree diffs, and call-stack trees when they communicate a relationship faster than prose.
- Use normative language deliberately: **must** for requirements and invariants, **will** for accepted design, **may** for permitted behavior, and **proposed** or **open** for unsettled choices.
- Do not preserve brainstorming history, rejected details with no lasting value, generic best practices, or implementation trivia that the code will make obvious.
- Do not make a proposed system sound already implemented. Cite code, documents, runtime evidence, or experiments for consequential claims about current behavior.
- Keep one canonical document. Research notes and worker handoffs provide evidence; they do not become parallel designs.
- Review in passes: structure and section ownership; product contract and scope; live evidence, options, and architecture; grounded program design and slices; cross-section consistency; then prose and publication. Do not polish a section while its design or ownership is unsettled.
- Keep one temporary Working State section while drafting and remove it before publication. Decisions and open questions remain authoritative in the sections that own them.

## Canonical full TDD template

Delete optional sections that do not apply. Do not leave empty headings or write filler to justify their presence.

````markdown
# <Project or change> TDD

**Authors:** <owners>

**Created Date:** YYYY-MM-DD

**Status:** Draft | In Review | Accepted | Superseded

**Reviewers:** <people responsible for product, architecture, implementation, or operations review>

## Working State

<Temporary while drafting: current pass, accepted-through gate, blockers, reopening conditions, and later-pass review queue. Remove before publication.>

## Objective

<One short paragraph stating the observable user or platform outcome, the essential safety or quality bar, and any deployment environments that must behave consistently. Do not describe the implementation here.>

## Context

<Only the current behavior, motivating problem, prior decisions, and constraints a fresh reader needs before evaluating the proposal. Link accepted product requirements, issues, ADRs, and evidence instead of retelling them.>

## Requirements

### Product

<Observable behavior, policy, and scope. Organize by user capability when useful. Use one direct sentence per requirement bullet in the normal case. Include explicit deferred capabilities or non-goals when they prevent likely scope creep. Omit this subsection when an issue or accepted product brief already settles the outcome and the TDD adds no product design.>

### Technical

- <Testable invariant or system constraint, independent of the chosen code structure.>

## Architecture

<Define system boundaries, ownership, sources of truth, trust boundaries, persistent model meaning, the semantics of stable cross-system contracts, state transitions, and failure or compatibility invariants. Show the current and proposed end-to-end flow when the difference matters. Do not discuss exact repository schemas, file layout, or internal helper signatures here.>

### System boundaries

<Small component/ownership diagram and a concise explanation of each participating component's responsibility. Show deployable systems, external actors, meaningful ownership or trust boundaries, and cross-system calls. Nest internal state under its owner or omit it. Represent a component once unless its internal roles materially affect the decision.>

### <Important sequence, policy, trust, state, or failure boundary>

<Use a sequence diagram, contract example, state transition, or focused prose. State where identity, authority, business rules, and durable state are enforced.>

### Decisions and alternatives

- **<Decision>:** <choice and the rationale necessary to preserve it.>
- **Rejected — <alternative>:** <specific reason it loses under the accepted requirements.>

### Open architecture questions

- <Question — owner — consequence if unresolved.>

## Program Design

<Describe how repository code will realize the accepted architecture. Start with public or durable contracts, then follow the execution path inward. Use only enough detail for the next one to three slices to be implemented without making consequential choices implicitly.>

### Contracts and data shapes

<Important endpoint, event, schema, type, or method signatures grounded in the existing callers, types, and framework conventions they extend. Mark public, internal, and durable contracts. Include bounds, validation, compatibility, and error shapes when they affect behavior.>

### Code layout

```text
<small file-tree diff using +, ~, and - with one-line responsibilities>
```

### Control flow

```text
<small call-stack or control-flow tree; use diff notation when the change is the point>
```

### Failure, concurrency, and compatibility behavior

<Only the cases that influence structure: retries, replay, idempotency, serialization, partial failure, version overlap, migration, rollback, and degraded behavior.>

## Verification

<Map each important requirement or boundary to evidence. Prefer a compact table. State the realistic dependency level: unit, integration with real services, end-to-end, browser, request/response, trace, failure injection, or operational smoke test. Do not list generic test commands without saying what claim they prove.>

| Boundary or claim | Required evidence |
| --- | --- |
| <claim> | <test, command, probe, screenshot, trace, or observed transition> |

## Deployment and Rollout

<Migration order, reader/writer compatibility, flags, staged enablement, rollback, self-managed or multi-environment requirements, and cleanup. Omit when deployment is ordinary and no version overlap or release policy matters.>

## Observability

<Signals needed to operate the new behavior: trace continuity, structured events, redaction, bounded metric labels, dashboards, alerts, and ownership. Omit when existing telemetry covers the change without modification. Avoid prescribing dashboards and alerts before the failure modes are known.>

## Milestones

<Vertical delivery slices, not component phases. Each slice must provide observable behavior or retire a named risk, cross every required layer, preserve the accepted invariants, and leave the system coherent. The exit condition is evidence, not “code complete.”>

| Milestone | Deliverable | Exit condition |
| --- | --- | --- |
| 1. <walking skeleton or highest-risk path> | <small end-to-end behavior> | <observable proof or retired risk> |

## Resources

- <Issue, product brief, ADR, code path, experiment, prior design, or operational evidence used by this proposal>
````

## Section ownership

### Objective

State the outcome in one paragraph. A good objective can be evaluated without knowing the chosen architecture. Include the safety, durability, or consistency bar only when it is part of the outcome.

Do not put motivation history, component names, milestones, or solution detail here.

### Context

Give the reader the minimum facts needed to judge the proposal. Explain the existing constraint before the proposed response to it. Link to stable sources and summarize only the part that changes the decision.

Do not turn the research journey into a narrative or use this section as a miscellaneous background dump.

### Requirements

Product requirements describe visible behavior, policy, committed scope, and non-goals. Technical requirements describe testable invariants and constraints that any acceptable architecture must satisfy.

Requirements must not encode the chosen implementation unless the mechanism itself is an accepted constraint. A requirement constrains every acceptable solution; an architecture invariant states what the selected boundary guarantees or enforces. Write one direct sentence per requirement bullet in the normal case. If a bullet needs several sentences, split multiple requirements or move rationale and implementation detail to their owning sections. If the issue already contains accepted product requirements, link it and omit or briefly restate only the requirements needed to review the technical design.

### Architecture

Architecture explains components, services, queues, stores, ownership, trust, durable state, persistent model meaning, and the semantics of their cross-system interactions. It is where reviewers decide expensive-to-reverse boundaries.

State who owns each business rule and source of truth. Show important read, write, asynchronous, approval, and recovery sequences. Make security, failure isolation, durability, compatibility, and deployment invariants explicit when they matter.

For a new or stronger trust, durability, or failure guarantee, state the existing guarantee, the required delta, the concrete threat or failure, and why the established pattern is insufficient. Evaluate the actual hosted, self-managed, version-overlap, and rollback states before adding compatibility machinery.

Architecture diagrams show deployable systems, external actors, meaningful ownership or trust boundaries, and cross-system calls. Nest internal state under its owner or omit it. Do not put exact repository schemas, file layouts, private types, helper functions, or detailed call stacks here.

### Program Design

Program design explains the shape of the code inside the accepted architecture: file changes, important types and signatures, adapters, call stacks, state machines, concurrency mechanics, and error handling.

This is where exact endpoint schemas and repository-level contracts live, grounded in existing callers, types, framework conventions, validation, durable context, and runtime guarantees. An agent's plausible but undesirable implementation choices should become visible here before code review. Use exact code when syntax materially constrains the design and pseudocode when only the algorithm or flow matters. Omit trivial initialization and undisputed implementation bodies. Prefer focused examples and small structural diagrams to exhaustive prose or near-complete implementation. Design the next one to three slices; distant detail will become stale.

### Verification

Verification is the review contract. Tie evidence to requirements, boundaries, and failure modes. A passing unit suite does not prove a cross-service authorization path, durable replay behavior, UI result, deployment sequence, or operational signal.

Name realistic evidence and the environment required to obtain it. Never weaken verification because local setup is inconvenient; record the setup gap or make it part of the work.

### Deployment and Rollout

Include this section when releases overlap, schemas or durable formats change, flags gate behavior, migrations are irreversible, multiple deployment models differ, or rollback requires coordination. State ordering and safe rollback directly.

### Observability

Include this section when the change creates a new service, background path, operational failure mode, trust boundary, or support burden. Define what must be observable and redacted. Metrics and alert thresholds should reflect actual failure modes and bounded cardinality.

### Milestones

Organize delivery vertically. Prefer a walking skeleton or the highest-risk end-to-end path first. Do not plan all schema work, then all service work, then all API work, then all UI work.

Each milestone includes the behavior or risk it proves, its dependencies and non-goals when useful, and the evidence required for review. Review after a slice when its code quality, product behavior, or architecture remains uncertain.

## Review standard

Before accepting a proposal, Sean and the responsible reviewers should be able to:

- explain the end-to-end path and ownership boundaries without reading the implementation;
- identify the consequential decisions and strongest rejected alternative;
- see the proposed code shape for the next slice;
- trace every important requirement and invariant to verification evidence;
- understand release ordering, rollback, and operational behavior where they matter; and
- name every remaining decision and who owns it.

Before detailed coherence review, they should also be able to name the requirement or concrete failure that justifies every new guarantee, abstraction, store, and compatibility mechanism. Delete or narrow any that cannot pass that test.

If the document cannot support those answers, do not compensate with more prose. Find the missing decision, evidence, diagram, or contract.
