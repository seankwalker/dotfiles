# Dotfiles

This repository is installed with Git metadata in `~/.dotfiles/.git` and the
working tree at `$HOME`. Submodules therefore live at their normal home paths.

## Install on a new machine

Fetch `install.sh` from the `master` branch, inspect it, and run it:

```sh
curl -fsSL https://raw.githubusercontent.com/seankwalker/dotfiles/master/install.sh \
  -o /tmp/dotfiles-install.sh
sh /tmp/dotfiles-install.sh
```

The installer initializes the repository, checks out the configured branch,
and runs `git submodule update --init --recursive` with `$HOME` as the
worktree. It uses HTTPS for public repository access by default; override the
remote with `DOTFILES_REPO_URL` when needed.

If a tracked path already exists on the machine, the installer moves it to a
timestamped `.dotfiles-backup-*` directory before checking out the repository.

After installation, open a new shell. `dotf pull` also updates initialized
submodules.
