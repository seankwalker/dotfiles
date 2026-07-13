#!/bin/sh

set -eu

repo_url=${DOTFILES_REPO_URL:-https://github.com/seankwalker/dotfiles.git}
branch=${DOTFILES_BRANCH:-master}
git_root=${DOTFILES_GIT_ROOT:-"$HOME/.dotfiles"}
work_tree=${DOTFILES_WORK_TREE:-"$HOME"}

die() {
    printf 'dotfiles: %s\n' "$*" >&2
    exit 1
}

command -v git >/dev/null 2>&1 || die 'git is required'
[ -n "${HOME:-}" ] || die 'HOME is not set'
[ "$work_tree" = "$HOME" ] || die 'this installer currently supports HOME as the worktree only'
[ "$git_root" != "$HOME" ] || die 'the Git directory must not be HOME'

mkdir -p "$git_root"

# Keep only .git under ~/.dotfiles; the actual checkout belongs in $HOME.
if [ -d "$git_root/.git" ]; then
    extra_entry=$(find "$git_root" -mindepth 1 -maxdepth 1 ! -name .git -print -quit)
    [ -z "$extra_entry" ] || die "$git_root is already a checkout; move it aside before installing"
    git_dir="$git_root/.git"
elif [ -e "$git_root/HEAD" ] || [ -e "$git_root/config" ]; then
    die "$git_root looks like a bare repository; use a non-bare Git directory containing .git"
else
    git init "$git_root" >/dev/null
    git_dir="$git_root/.git"
fi

# Tell Git that this metadata directory is non-bare and has a separate worktree.
git --git-dir="$git_dir" config core.bare false
git --git-dir="$git_dir" config core.worktree "$work_tree"
git --git-dir="$git_dir" config status.showUntrackedFiles no
git --git-dir="$git_dir" config submodule.recurse true

if git --git-dir="$git_dir" config --get remote.origin.url >/dev/null 2>&1; then
    git --git-dir="$git_dir" remote set-url origin "$repo_url"
else
    git --git-dir="$git_dir" remote add origin "$repo_url"
fi

git --git-dir="$git_dir" fetch origin "$branch"

# Back up untracked files that checkout would otherwise overwrite.
backup_dir=
backup_count=0
# Compare the remote tree with the current index so rerunning is harmless.
while IFS= read -r path; do
    [ -n "$path" ] || continue
    target="$work_tree/$path"

    if git --git-dir="$git_dir" ls-files --error-unmatch -- "$path" >/dev/null 2>&1; then
        continue
    fi

    if [ -e "$target" ] || [ -L "$target" ]; then
        if [ -z "$backup_dir" ]; then
            backup_dir=$(mktemp -d "$work_tree/.dotfiles-backup-XXXXXX")
        fi
        mkdir -p "$backup_dir/$(dirname "$path")"
        mv "$target" "$backup_dir/$path"
        backup_count=$((backup_count + 1))
    fi
done <<EOF
$(git --git-dir="$git_dir" ls-tree -r --name-only "origin/$branch")
EOF

cd "$work_tree"
# Create or fast-forward the local branch without discarding local changes.
if git --git-dir="$git_dir" show-ref --verify --quiet "refs/heads/$branch"; then
    git --git-dir="$git_dir" --work-tree="$work_tree" checkout "$branch"
    git --git-dir="$git_dir" --work-tree="$work_tree" merge --ff-only "origin/$branch"
else
    git --git-dir="$git_dir" --work-tree="$work_tree" checkout -b "$branch" --track "origin/$branch"
fi

# The submodule paths are relative to $HOME, so z lands at ~/bin/z.
git --git-dir="$git_dir" --work-tree="$work_tree" submodule sync --recursive
git --git-dir="$git_dir" --work-tree="$work_tree" submodule update --init --recursive

if [ "$backup_count" -gt 0 ]; then
    printf 'Backed up %s existing path(s) to %s\n' "$backup_count" "$backup_dir"
fi
printf 'Dotfiles installed. Git metadata: %s\n' "$git_root/.git"
printf 'Worktree: %s\n' "$work_tree"
