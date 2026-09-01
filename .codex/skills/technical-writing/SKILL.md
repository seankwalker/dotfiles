---
name: technical-writing
description: Write or revise engineering prose for clarity and human readability. Use for code comments, documentation, TDDs, RFCs, design docs, PR descriptions, review comments, and other technical explanations. Apply when creating new prose or rewriting existing prose. Do not use merely because a task involves code if no prose is being written.
---

# Technical Writing

Write technical prose that another engineer can understand quickly and accurately.

Optimize for comprehension, not sophistication, exhaustiveness, or information density.

## Load the relevant guidance

- For code comments, docstrings, or API comments, read [references/code-comments.md](references/code-comments.md) completely before drafting.
- For documentation, TDDs, RFCs, design documents, runbooks, ADRs, or structured PR descriptions, read [references/technical-documents.md](references/technical-documents.md) completely before drafting.
- For short explanations, review comments, or unstructured PR prose, use this core guidance by itself.

When a more specific skill or template applies, follow it for the artifact's content, structure, and lifecycle. Use this skill to make the resulting prose clear and accurate.

## Establish meaning before wording

Before drafting or rewriting, state in one sentence what the piece of writing must help its reader understand or do. Identify what each comment, paragraph, or section contributes to that purpose.

If you cannot state a comment's, paragraph's, or section's purpose plainly, do not make its existing wording smoother. Inspect the source material, ask a focused question, split or move the text, or remove it.

When the prose describes an existing system, inspect the relevant code or authoritative documentation before making technical claims. Do not infer behavior from a type name, dead code, a familiar pattern, or plausible-sounding prose.

Distinguish verified facts, assumptions, requirements, decisions, and open questions. Preserve their status and degree of certainty. Do not turn a possibility into a fact, an intention into existing behavior, or an unresolved question into a decision.

## Write for a fresh reader

Write for someone who knows the codebase and technical domain but did not participate in the conversation or reasoning that produced the change.

Before writing, determine:

1. What does the reader need to know?
2. What would be surprising or unclear from the code or surrounding context?
3. What rationale will matter when someone encounters this later?

Include those things. Leave out the rest. Prior investigation and discussion are source material, not a structure the final prose must preserve.

## Order information by reader dependency

Introduce a concept or constraint before relying on it. Do not make the reader decode an implementation detail before they know why it matters.

Within a comment, paragraph, or section, state the point before supporting detail. Across a longer piece, establish the information that the conclusion depends on before asking the reader to understand that conclusion.

Each statement or paragraph should follow naturally from what precedes it. If the reader cannot tell why it appears where it does, move it, connect it, or remove it.

## Use ordinary, established language

Use the simplest wording that expresses the idea accurately. Technical writing should not sound more specialized than the underlying idea is.

Use terminology already present in the codebase or established in the relevant domain, but do not assume that an implementation name explains itself. Explain a component's role before introducing its type or field name when the reader needs that context.

If a new term is necessary, define it and use it consistently. Do not casually rename the same concept or invent a category, metaphor, or synonym merely to make an explanation sound precise.

Prefer an ordinary clause to a dense noun phrase:

> the LLM call used during setup

rather than:

> the setup-time selection LLM call

Use metaphors such as "spine," "seam," "surface," or "arm" only when they are established concepts and genuinely make the explanation easier to understand.

Prefer active statements with concrete actors and actions. Name who does what, and add the relevant boundary or time when it matters. Replace vague pronouns, abstract verbs, and dense noun clusters when they force the reader to reconstruct the behavior.

## Keep each statement focused

A sentence should normally make one main point. Split sentences with several qualifications, exceptions, parentheticals, or separate pieces of reasoning.

State the rule, behavior, or conclusion directly. Avoid slogans and framing such as "the key insight," "the critical distinction," or "the load-bearing abstraction" when the underlying fact can stand on its own.

Assume a competent reader. Explain project-specific behavior and constraints that the reader cannot reasonably infer, but do not explain ordinary programming concepts merely to make the prose self-contained.

Treat controlled-language practices as diagnostics, not as a compression target or a restricted vocabulary. A shorter sentence is worse when it drops the qualifier, context, or rationale that makes the claim true.

## State default invariants briefly

State an important default when a new path or boundary could otherwise make it ambiguous. Use one direct, positive sentence. Do not justify why the system preserves expected behavior or list examples unless a surprising exception, enforcement point, or ownership boundary matters.

Prefer:

> Platform tools apply current resource authorization at execution time.

rather than explaining at length that enabling a platform tool does not bypass those controls.

## Preserve necessary rationale

Include enough rationale for a future engineer to understand a decision or constraint and avoid accidentally undoing it. Do not include every fact that contributed to it.

Ask:

> Would omitting this information make a future engineer meaningfully more likely to misunderstand the system or make the wrong change?

If not, omit it or link to the place where the detail belongs.

## Rewrite meaning, not wording

Preserve the source's technical meaning, important rationale, and level of certainty. Do not preserve its structure merely because it already exists.

Reorder information, split sentences or sections, replace invented terminology, and remove reasoning history when doing so makes the meaning easier to recover. Do not make the result less precise merely to make it shorter.

If the source is ambiguous or appears incorrect, investigate or ask rather than silently choosing the most fluent interpretation.

## Resist prompt residue

Do not include an abandoned approach, experiment, caveat, or back-and-forth discussion merely because it was prominent in the preceding conversation. Preserve it only when the reader needs it to understand the current system or avoid a likely mistake.

The final prose should describe the relevant truth, decision, or instruction—not the history of arriving at it.

## Final pass

Read the result as if the preceding conversation did not exist. Check:

- Is the purpose obvious on the first read?
- Are claims about existing behavior verified?
- Does the prose preserve what is known, proposed, required, and unresolved?
- Does information appear before later statements depend on it?
- Are code identifiers and technical terms understandable in context?
- Does each sentence, paragraph, or comment have a clear purpose?
- Can anything be removed without making the reader less able to understand or maintain the system?

If the prose still reads like a polished reasoning transcript, reorganize it.
