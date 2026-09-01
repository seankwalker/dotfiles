# Technical Documents

Use this guidance with the core technical-writing skill for documentation, TDDs, RFCs, design documents, runbooks, ADRs, and other structured engineering prose.

## Follow the governing format

Use the artifact-specific template or skill when one exists. It determines what belongs in the document, its required sections, and its lifecycle. This reference governs reader flow and clarity; it does not replace an ADR, TDD, runbook, or PR-specific process.

## Establish the document model before drafting

Before drafting a new or structurally incoherent substantial document, establish:

1. who needs to read the document;
2. what they should understand or be able to decide afterward;
3. what context they can reasonably be expected to have;
4. which verified facts, requirements, proposals, accepted decisions, and open questions belong in it;
5. the section outline and one sentence defining each section's job; and
6. which unresolved decisions prevent accurate drafting.

Do not polish prose while important material is misclassified or while an unresolved decision would make the draft speculative. When revising an existing document, preserve accepted working state and use a reverse outline to expose what each current paragraph is doing before moving or rewriting it. Define explicit section jobs only for new, mixed-purpose, or disputed sections when the rest of the structure is already coherent.

Depending on the document, the material may include:

- verified current behavior;
- requirements and constraints;
- proposals or decisions;
- rationale and evidence;
- consequences and tradeoffs;
- unresolved questions; and
- implementation details or follow-up work.

Do not force every category into every document. Use the governing format and the document's purpose to decide what belongs.

## Plan the reader's path

Give each section one clear job, then order sections by what the reader needs to understand next. Within a section, make each paragraph answer a question raised naturally by what precedes it.

When orientation is needed, open a major section with enough cohesive prose to establish the shape of the subject and why the following detail matters. Go directly to a list or table when the heading and labels already provide that context. Use bullets, tables, diagrams, code, or pseudocode for information readers need to scan or compare.

## Separate unlike claims

Keep existing behavior, requirements, proposals, decisions, and open questions distinguishable in both wording and placement. Do not make a proposed design sound implemented or use present-tense system description for behavior that has not been verified.

Explain why a code identifier, type, endpoint, or subsystem matters before adding implementation-specific detail about it. The existence of a name in the codebase does not by itself prove what the system does.

When code is offered as precedent, establish whether it is an active supported path, a historical artifact, dead or vestigial code, or proposed work. Check callers, tests, history, documentation, and runtime evidence in proportion to the claim; the presence of a route, type, or helper is not enough.

Avoid unsupported causal claims. Before writing that one design "requires," "prevents," or "therefore" causes another outcome, verify the dependency or state the uncertainty.

## Keep the document at the right scope

Include detail that helps the intended reader understand, decide, implement, or operate what the document owns. Move, link, or omit detail that belongs to another artifact.

Do not fill an unresolved design gap with plausible implementation detail merely to make the document feel complete. Record the open question or defer it to the artifact that owns the design.

When revising an existing document, fix its outline before polishing sentences. Split, combine, move, or remove sections when their current order does not support the reader's path.

## Choose structures deliberately

Use bullets for discrete items such as requirements. A requirement bullet should normally be one direct sentence. If it needs several sentences, split it or move its rationale or design detail to the section that owns that material.

Use a table when readers need to compare repeated fields or trace exact mappings across several items. Each column must add distinct information, its heading must describe the cells accurately, and the cells should remain short enough to compare. State a shared invariant once above the table instead of repeating it in every row or adding duplicate columns.

Use exact code when syntax or a contract materially constrains the design. Validate exact examples with the relevant compiler, schema generator, or framework when practical; otherwise label them as illustrative. Use pseudocode when the algorithm matters but repository syntax does not. Introduce a code identifier through its purpose before showing its exact name, and omit trivial initialization or undisputed implementation bodies.

Add a diagram only when it makes a relationship, boundary, or sequence materially easier to understand. Represent a component once unless the distinction between its internal roles is itself important. Label service and ownership boundaries clearly enough that readers do not mistake two endpoints for two systems.

## Review in passes

Review a substantial document in this order:

1. Structure and section ownership
2. Technical meaning and source grounding
3. Cross-section consistency
4. Sentence clarity and concision
5. Formatting and publication

Do not mix all five passes into a section-by-section rewrite. Capture feedback that belongs to a later pass without working it immediately. Return to an earlier pass only when new evidence or a contradiction invalidates it.

During the consistency pass, check for:

- scope or behavior contradictions;
- names that drift across prose, diagrams, tables, and examples;
- interfaces whose callers and implementations disagree;
- requirements with no design or verification path;
- implementation detail with no requirement, constraint, or architectural rationale; and
- milestones that promise behavior excluded or deferred elsewhere.

## Review the finished document

Read only the headings, then the first sentence of each paragraph. They should still reveal a coherent path through the document.

Check:

- Does the opening establish why the document exists?
- Does each section have one recognizable purpose?
- Does every paragraph appear after the context it depends on?
- Are existing facts, requirements, proposals, decisions, and unknowns distinguishable?
- Are implementation names explained rather than merely introduced?
- Has any open question been silently converted into a decision?
- Does the document include detail that belongs in a more specific artifact?
