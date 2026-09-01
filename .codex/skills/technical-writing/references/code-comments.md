# Code Comments

Use this guidance with the core technical-writing skill when writing or revising comments, docstrings, or API comments.

## Decide whether a comment belongs

Add a comment only when it contributes information the code cannot express clearly enough. First consider whether better naming, a smaller function, a clearer type, or simpler control flow would remove the need for it.

A useful comment usually explains:

- why a surprising decision exists;
- an invariant or constraint the code cannot enforce;
- behavior that is easy to misunderstand;
- an important external requirement; or
- a trap a future change could reintroduce.

Do not translate the code into English, repeat a function or variable name, narrate implementation steps, or preserve the history of how the code was written.

## Match the comment to its audience and scope

Place the comment as close as possible to the code it explains.

- Use API comments and docstrings for contracts a caller needs to know: inputs, outputs, errors, side effects, ordering, or compatibility guarantees.
- Use inline comments for local rationale or constraints that matter while changing the implementation.
- Do not put a broad architectural explanation above a narrow exception. Link to the durable source when the full explanation belongs elsewhere.

Keep the comment proportional to the risk of misunderstanding. A subtle security or compatibility constraint may need a paragraph. A local non-obvious choice may need one sentence.

## Explain the reason directly

Lead with the behavior or constraint that matters. Include the reason needed to preserve it, but not the complete investigation that discovered it.

Bad:

```ts
// A reliability threshold, not a cost-optimal one. The A/B put the cost
// crossover near 200 tools, but several larger catalogs were pruned...
const TOOL_SEARCH_DIRECT_EXPOSURE_MAX_MCP_TOOL_COUNT = 50;
```

Better:

```ts
// Use tool search above 50 MCP tools to leave room under the provider's tool
// limit for built-in and client-provided tools.
const TOOL_SEARCH_DIRECT_EXPOSURE_MAX_MCP_TOOL_COUNT = 50;
```

Do not use an issue, ticket, or discussion link as the only explanation. State the durable reason in the comment; add a link only when the external material remains useful and available to the intended reader.

## Keep comments true over time

Write comments about the invariant, requirement, or present behavior—not about the implementation session. Avoid phrases such as "for now," "currently," or "eventually" unless temporary behavior is itself important and has a clear end condition.

When changing the code, update or remove nearby comments that are no longer accurate. A stale comment is worse than no comment because readers treat it as deliberate guidance.

## Review the finished comment

Check:

- Does the comment say something the code does not already say?
- Is it attached to the smallest relevant scope?
- Does it explain why the behavior or constraint matters?
- Would a future code change make it misleading?
- Can it be shorter without losing the information that justifies its existence?
