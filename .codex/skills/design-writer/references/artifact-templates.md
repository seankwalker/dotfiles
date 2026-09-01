# Design Project Research Templates

These are supporting research and slice-contract formats. The canonical issue-design and full-TDD structure lives in [tdd-template.md](tdd-template.md).

Use only the supporting artifacts needed for the selected process depth. Adapt them to repository-local formats rather than creating parallel documents, and synthesize their evidence into one canonical design.

## Product Contract

```markdown
## Product Contract

**Outcome:** <observable user or platform result>

**Evidence:** <why this is worth doing>

**Success:**
- <observable measure or acceptance probe>

**In scope:**
- <committed behavior>

**Non-goals:**
- <excluded behavior and necessary rationale>

**Constraints:**
- <product policy or external constraint>

**Open product decisions:**
- <question, owner, and consequence>
```

## Architecture Question Map

```markdown
| Question | Why it matters | Evidence needed | Coupled questions | Proposed track |
| --- | --- | --- | --- | --- |
| <decision question> | <consequence> | <code, docs, runtime probe> | <question IDs> | <track> |
```

Phrase questions without assuming the favored implementation. Include reuse and a narrow special case among the options when either is feasible.

## Working State

Keep one temporary block in the canonical design rather than creating a separate artifact. Decisions and open questions remain authoritative in their owning sections; this block only makes the next review or resumed session cheap. Remove it before publication.

```markdown
## Working State

**Current pass:** <structure | product contract | architecture | program design | consistency | prose and publication>

**Accepted through:** <last gate Sean accepted>

**Blockers:** <questions that prevent the current gate from completing>

**Reopen if:** <new evidence, falsified assumption, contradiction, or material consequence that would change an accepted tradeoff>

**Later-pass review queue:** <captured feedback that does not belong to the current pass>
```

## Research Track Contract

```markdown
## Research Track: <decision-oriented name>

**Decision to enable:** <one primary architecture question>

**Product context:** <minimum accepted outcome and scope needed>

**Inspect:**
- <paths, services, contracts, runtime state>

**Non-scope:**
- <areas and decisions this worker must not own>

**Known decisions:**
- <accepted constraint the worker must preserve>

**Required evidence:**
- <source or bounded experiment>

**Return:**
1. Verified current behavior with source references
2. Constraints and invariants
3. Feasible options and tradeoffs
4. Recommendation
5. Dependencies or conflicts
6. Decisions still requiring Sean
```

## Research Handoff

```markdown
**Question:** <decision investigated>

**Current behavior:**
- <verified fact, source, and whether the path is active, historical, vestigial, or proposed>

**Constraints:**
- <constraint and consequence>

**Options:**
- <option>: <tradeoff>

**Recommendation:** <choice and concise rationale>

**Dependencies or conflicts:** <other tracks or accepted decisions>

**Needs decision:** <one question, or "Nothing">
```

## Architecture Synthesis

```markdown
## System Architecture

### System boundaries
<small component or ownership diagram>

### End-to-end sequences
<only the sequences that settle meaningful interactions>

### Responsibilities and sources of truth
| Concern | Owner | Contract | Enforcement point |
| --- | --- | --- | --- |

### Architecture invariants
- <testable property the design must preserve>

### Decisions
- **<decision>:** <choice and rationale>

### Rejected alternatives
- **<alternative>:** <why it was rejected>

### Open questions
- <question, owner, and blocking consequence>
```

## Vertical Slice Map

```markdown
| Slice | Observable proof or retired risk | End-to-end path | Dependencies | Verification |
| --- | --- | --- | --- | --- |
| <slice> | <behavior someone can exercise> | <components crossed> | <prior decision/slice> | <test, request, screenshot, trace> |
```

## Slice Execution Contract

```markdown
## Slice: <name>

**Outcome:** <observable behavior or retired risk>

**End-to-end path:** <entrypoint through final state/result>

**In scope:**
- <behavior and components>

**Non-goals:**
- <excluded work>

**Accepted architecture:**
- <decision or invariant this slice implements>

**Program design:**
- File-tree changes: <small diff tree>
- Call-stack changes: <small call tree>
- Contracts and types: <important signatures or schemas>
- Failure and compatibility behavior: <important cases>

**Acceptance claims:**
- <observable claim>

**Verification:**
- <command or realistic evidence for each claim>

**Stop conditions:**
- <new product choice, architecture conflict, or falsified assumption>
```
