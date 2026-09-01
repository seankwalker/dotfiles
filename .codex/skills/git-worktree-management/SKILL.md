---
name: git-worktree-management
description: Manage task-specific Git worktrees with `~/bin/git-manage-worktree`. Use when Codex is working from a parent task and needs a separate worktree for a Linear child issue, when the user asks to add, locate, or remove a worktree, or whenever a Linear issue's suggested Git branch name should become a worktree. Do not use merely because Codex was launched inside a worktree the user already prepared.
---

# Manage Git Worktrees

Run the full helper path from within the relevant Git repository. Shell aliases are not available in Codex's non-interactive execution environment.

1. Resolve an existing worktree with `~/bin/git-manage-worktree path <branch>`.
2. If it exists, use the printed path as the explicit `workdir` on every subsequent tool call. Do not narrate this routine lookup.
3. If it does not exist, create it with `~/bin/git-manage-worktree add <branch> [start-point]`, mention the creation briefly, and use the printed path as `workdir` thereafter.

For Linear work, pass the suggested Git branch name verbatim. `add` attaches an existing local branch when present; otherwise it creates the branch from `main` by default. Provide `[start-point]` only when a new branch requires another base. Worktree directory names flatten `/` to `-`, but always use the path printed by `path` or `add` rather than reconstructing it.

Working directories do not persist between tool calls. Setting `cd` in one command has no effect on the next, so pass the resolved worktree path as `workdir` every time.

Worktree creation does not open a UI by default. Humans can pass `-t`/`--tmux` to open the new worktree in a detached tmux window, `-z`/`--zed` to run `zed <worktree-path>`, or both. The same flags work for existing worktrees: `~/bin/git-manage-worktree open -z <branch>` reopens one in Zed, while `open -t <branch>` opens a side-by-side tmux window with `codex resume` on the left and an idle worktree shell on the right. The flags can be combined, and bare `open <branch>` retains the tmux behavior. These launchers do not change Codex's working directory; Codex must not call them unless the user explicitly requests opening an application or tmux window.

Treat removal as destructive. Never run `~/bin/git-manage-worktree rm`, with or without `-d`, unless the user explicitly authorizes removal. A completed ticket alone is not authorization. The command accepts multiple branches in one batch (`rm -d <branch> [branch ...]`); flags apply to every target, and `-d` also force-deletes each local branch. Mention worktree handling only when creating one, requesting destructive authorization, or reporting a genuine blocker.

Do not switch branches in the parent worktree or create/remove anything during lookup. Consult `~/bin/git-manage-worktree` if exact behavior or error handling matters.
