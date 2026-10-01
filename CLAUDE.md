# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Workflow

When a tool is added/removed or a tool configuration is changed you must update the README.md file.

## Installation

```sh
./install.sh
```

Runs from any location — resolves its own path for symlinks. To bootstrap private/machine-specific config, set `EXTRA_DOTFILES_GIST` to a gist URL before running; the top-level `install.sh` runs that gist bootstrap **last**, after all other installers. Claude does not typically need to run this install script unless explicitly asked to.

## Repository structure

| Path                         | Purpose                                                                                                 |
| ---------------------------- | ------------------------------------------------------------------------------------------------------- |
| `install.sh`                 | Top-level installer: delegates to per-tool installers in order; optional `EXTRA_DOTFILES_GIST` step last |
| `homebrew/install.sh`        | Homebrew setup (macOS only)                                                                             |
| `zsh/install.sh`             | oh-my-zsh, spaceship-prompt, zsh-autosuggestions, `~/.zshrc` symlink                                    |
| `jujutsu/install.sh`         | jj binary (brew/GitHub release), config symlink, spaceship-jj prompt section                            |
| `jujutsu/config.toml`        | Shared jj config (linked to `~/.config/jj/conf.d/dotfiles.toml`): auto-tracks `main` and `osvi/*` bookmarks, push bookmark prefix `osvi/` |
| `fzf/install.sh`             | fzf binary (brew/apt/dnf/yum); used by `gitpod/gitpod.zsh`                                              |
| `node/install.sh`            | nvm + Node.js LTS                                                                                       |
| `tmux/install.sh`            | Symlinks `~/.tmux.conf`                                                                                 |
| `zsh/.zshrc`                 | Symlinked to `~/.zshrc`. Loads oh-my-zsh, then sources per-tool zsh files                               |
| `git/git.zsh`                | Git aliases and helper functions (stash/rebase workflows)                                               |
| `jujutsu/jujutsu.zsh`        | Jujutsu aliases and shell completions                                                                   |
| `docker/docker.zsh`           | Docker Compose aliases                                                                                  |
| `gitpod/gitpod.zsh`           | Gitpod environment management (oc command + completions)                                                |
| `tmux/.tmux.conf`            | Symlinked to `~/.tmux.conf`. Focused on OSC 52 clipboard passthrough for SSH                            |
| `tmux/tmux.zsh`              | `yy` function: pipe command output to macOS clipboard via OSC 52 (`echo hello \| yy`)                   |

## Key design decisions

**Symlinks, not copies.** The installer creates symlinks (`ln -sf`) so edits in the repo take effect immediately without re-running the installer. Existing files are backed up with a timestamp suffix.

**SSH clipboard via OSC 52.** `tmux/.tmux.conf` enables `allow-passthrough on` and `set-clipboard on` so the escape sequence reaches the host terminal through tmux. `focus-events on` forwards focus events to apps inside tmux.

