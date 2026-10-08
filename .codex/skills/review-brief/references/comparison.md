# Resolve the comparison

The default target is committed `HEAD`. Pin it once with `git rev-parse HEAD`; use that SHA for all later reads and diffs. A supplied historical commit replaces the target. For a supplied range, preserve the requested endpoints and distinguish a literal endpoint diff from a branch merge-base comparison.

## Gather evidence

Inspect repository root, `git status --short`, current branch (possibly detached), remotes, local/remote refs, and tracking configuration. Useful commands include:

```sh
git rev-parse --show-toplevel
git status --short
git branch --show-current
git remote -v
git for-each-ref --format='%(refname:short) %(upstream:short)' refs/heads refs/remotes
git symbolic-ref --quiet refs/remotes/origin/HEAD
```

`origin` is an example, not a guaranteed remote. A feature branch's upstream is often its published copy, not its intended merge target.

Choose a base using the strongest available evidence:

1. An explicit user-supplied base or range.
2. The matching PR's base repository/ref from configured tools or `gh pr view --json url,baseRefName,headRefName,headRefOid,body`. Verify repository and branch identity, especially for forks. If the PR head differs from the pinned local target, report that mismatch and keep local code as the target unless the user asked otherwise.
3. Documented repository/stack conventions or an explicitly configured integration upstream.
4. The relevant remote's default branch, then a plausible existing local default such as `main`, `master`, or `develop`, checked against history and scope.

For a local base branch, inspect its configured upstream. If that ref is strictly ahead of the local base, use it and explain the choice. If they diverge, investigate which represents the actual target; do not choose by commit date. Honor a user-specified exact SHA or explicitly local comparison.

Inspect existing refs first. If current remote state is necessary, a targeted fetch may update the relevant remote-tracking ref; do not switch, pull, rebase, reset, or merge. A failed/unavailable fetch can leave a useful local comparison: identify it as based on local refs, with freshness unverified.

Check stack metadata or ancestry when the branch contains unrelated prerequisite commits. Use the actual PR target for a stacked branch and explain the prerequisite briefly. Do not quietly compare the entire stack to the default branch.

When evidence supports a reasonable base, proceed and disclose the inference. Ask one focused clarification only when plausible bases materially change the story and available evidence cannot resolve them. Continue independent context gathering meanwhile.

## Pin and inspect

Resolve the chosen base to a SHA. With pinned `BASE_SHA` and `TARGET_SHA`, run:

```sh
git merge-base --all "$BASE_SHA" "$TARGET_SHA"
# Set MERGE_BASE_SHA to the single resolved common ancestor.
git diff --stat "$MERGE_BASE_SHA" "$TARGET_SHA" --
git diff --name-status --find-renames "$MERGE_BASE_SHA" "$TARGET_SHA" --
git log --oneline "$MERGE_BASE_SHA..$TARGET_SHA"
git diff --find-renames "$MERGE_BASE_SHA" "$TARGET_SHA" --
```

Two explicit diff endpoints are essential: `git diff <merge-base>` alone includes working-tree edits. Read target files with `git show "$TARGET_SHA:path/to/file"` when the working tree differs, and use `git show "$MERGE_BASE_SHA:path/to/file"` for previous behavior. Cite historical/deleted code with revision-qualified paths; do not link a current working-tree line that shows different code.

If a test run would exercise local edits instead of the pinned target, use a disposable snapshot with appropriate prerequisites or report that target validation was not run. Never stash or discard the user's edits.

No common ancestor can mean shallow history or the wrong base. Multiple merge bases require investigation rather than selecting an arbitrary SHA. Obtain missing history when feasible or name the unresolved comparison. Do not invent a baseline. An empty diff means no committed change in that comparison; report it without silently switching to local edits or another base. A moving target requires a fresh comparison, not a mixture of revisions.
