---
name: review-mcp-prs
description: >-
  This skill should be used when explicitly asked to audit one or more Kindo MCP integration or server pull requests by URL or number, regardless of author, or to explicitly approve already-audited passing PRs. It collects read-only evidence, coordinates bounded parallel review, and permits GitHub approval only through a separately invoked, live-revalidated command.
---

# Review MCP PRs

Accept explicit PR URLs or numbers. Ask for the repository when numbers do not identify it. Do not infer a PR from the current branch.

Read [references/repository-gates.md](references/repository-gates.md), [references/reviewer-task.md](references/reviewer-task.md), and [references/failure-message.md](references/failure-message.md) before reviewing a diff.

## Audit

1. Run `scripts/pr_batch.py collect --repo OWNER/REPO --output-dir PATH PR...`; preserve its JSON and diff artifacts as the coordinator evidence set.
2. Refuse to audit a collection marked unstable or incomplete. Launch at most six read-only workers in parallel, in waves, assigning each worker exactly one collected PR and its exact collected SHA. Give each worker the contract in `references/reviewer-task.md` and its evidence files.
3. Consolidate each worker handoff into this exact line format: `PR | audited SHA | pattern conformance | CI/tests | review findings | risks | verdict | reason`.
4. Set PASS only when every gate has direct evidence. Set ESCALATE for custom behavior, meaningful risk, ambiguity, or missing evidence. Set FAIL for a concrete defect or unresolved actionable finding. AI-review silence alone is never evidence that a PR is safe.
5. Record every unresolved thread-comment URL. A current non-actionable unresolved thread may remain only with a cited justification; an unresolved actionable thread is FAIL. Normalize each worker's snapshot to the coordinator audit types before saving: `pr`, `audited_sha`, `verdict`, `suggested_pr_message`, `unresolved_thread_urls`, `unresolved_thread_dispositions`, `issue_comment_urls`, `review_ids`, composite `expected_checks` and `required_check_keys` (`workflow::check`), `collection_errors`, `worker_evidence`, and `citations`. Set `suggested_pr_message` to a [failure-message draft](references/failure-message.md) for every FAIL and `null` for PASS or ESCALATE. After the one-line reports, add a `Suggested PR messages` section containing only the FAIL drafts.

Do not approve, post comments, request changes, modify, merge, or run test/check commands during audit. Do not ask workers to do so. Producing a draft does not authorize posting it: post comments only on a separate explicit request that names the target PRs. Never request changes or merge.

## Separate approval invocation

Only on a new explicit request to approve, run `scripts/pr_batch.py approve --repo OWNER/REPO --audit-file PATH` first. It is dry-run by default. It revalidates every PASS PR immediately before each approval and refuses new unresolved comments or threads.

To write approvals, require a second explicit confirmation and run `scripts/pr_batch.py approve --repo OWNER/REPO --audit-file PATH --execute --confirmation APPROVE_PASSING_PRS`. Never merge. Never add review text. Report every refusal; do not convert uncertainty into approval.

Use `scripts/pr_batch.py --help` for its safety and JSON-input contract.
