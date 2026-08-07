# Read-only PR worker contract

Inspect exactly one assigned PR at exactly the assigned head SHA. Do not substitute the current head. Read [failure-message.md](failure-message.md). Read only the coordinator's artifacts and GitHub evidence; do not run tests, checks, or local commands that modify files.

Assess scope and category: unified Python integration, remote-proxy exception, legacy-maintenance integration, or vendor server. Confirm the diff is one expected server plus only necessary standard registration, catalog, artifact, and root-lockfile changes. Flag extra integrations, unrelated cleanup, or category-pattern drift.

Inspect pattern conformance, authentication and security boundaries, network/filesystem/shell or dynamic execution, secrets, dependencies and lockfiles, schemas, side effects, errors, and test coverage. Reconcile all CI, smoke, AI-review, human-review, issue-comment, and unresolved review-thread evidence. Treat an AI review without findings as insufficient evidence by itself.

Use [repository-gates.md](repository-gates.md) for repository-specific gates. Cite every conclusion with a changed-file line, GitHub URL, artifact path, or local source path.

Record all unresolved thread-comment URLs, their actionable/non-actionable disposition and cited justification, plus issue-comment URLs and submitted-review IDs for the coordinator snapshot. For a PASSable unresolved thread, record `{ "classification": "non_actionable", "justification": "..." }`; any actionable thread is FAIL.

Return one compact handoff:

`PR | audited SHA | pattern conformance | CI/tests | review findings | risks | verdict | reason`

Then return a fenced `audit_snapshot` JSON object. Keep every list field a list for every verdict. Set `suggested_pr_message` to a ready-to-post Markdown draft that follows [failure-message.md](failure-message.md) for FAIL and `null` for PASS or ESCALATE. `unresolved_thread_dispositions` is always an object: use `{}` when no threads remain; each retained URL maps to `{ "classification": "non_actionable", "justification": "..." }`.

```audit_snapshot
{
  "pr": "https://github.com/OWNER/REPO/pull/NUMBER",
  "audited_sha": "SHA",
  "verdict": "PASS|ESCALATE|FAIL",
  "suggested_pr_message": null,
  "unresolved_thread_urls": [],
  "unresolved_thread_dispositions": {},
  "issue_comment_urls": [],
  "review_ids": [],
  "expected_checks": [],
  "required_check_keys": [],
  "collection_errors": [],
  "worker_evidence": [],
  "citations": []
}
```

Use PASS only with direct evidence for every applicable gate. Use ESCALATE for custom behavior, meaningful risk, ambiguity, missing evidence, or a gate requiring human judgment. Use FAIL for a concrete defect or unresolved actionable finding. Do not approve, request changes, post comments, merge, modify a PR or local files, or run test/check commands. A draft is not a comment: post one only after a separate explicit request names the target PRs. Never request changes or merge.
