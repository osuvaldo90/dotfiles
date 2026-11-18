# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Workflow

When a tool is added/removed or a tool configuration is changed you must update the README.md file.

## Installation

```sh
./install.sh [-o <package>]... | [-x <package>]...
```

Runs from any location — resolves its own path for symlinks. `-o` installs only the named packages, `-x` installs all except the named packages; they can not be combined. Dependencies are resolved from each package's `package.conf`. `DRY_RUN=1` prints the plan and exits. Claude does not typically need to run this install script unless explicitly asked to.

## Repository structure

| Path                          | Purpose                                                                                                   |
| ----------------------------- | --------------------------------------------------------------------------------------------------------- |
| `install.sh`                  | Parses `-o`/`-x`, resolves dependencies, runs each package's `install.sh`, links its `*.zsh` into `~/.config/dotfiles/zsh.d/` |
| `packages/<name>/`            | One installable package. `ls packages` lists them                                                         |
| `packages/<name>/package.conf`| Zsh-sourceable: `depends=(...)` dependencies, `os=(Darwin ...)` supported `uname -s` values (optional)     |
| `packages/<name>/install.sh`  | Optional package installer                                                                                |
| `packages/<name>/*.zsh`       | Optional shell config; sourced by `.zshrc` through `~/.config/dotfiles/zsh.d/`                            |
| `packages/homebrew/`          | Homebrew setup (macOS only)                                                                               |
| `packages/zsh/`               | oh-my-zsh, spaceship-prompt, zsh-autosuggestions, `.zshrc` (symlinked to `~/.zshrc`)                      |
| `packages/jj/`                | jj binary (brew/GitHub release), spaceship-jj, `config.toml` (linked to `~/.config/jj/conf.d/dotfiles.toml`: auto-tracks `main` and `osvi/*`, push prefix `osvi/`), `jj.zsh` aliases and prompt hook |
| `packages/fzf/`               | fzf binary (brew/apt/dnf/yum); used by `ona.zsh`                                                          |
| `packages/nvm/`               | nvm install and `nvm.zsh` loader                                                                          |
| `packages/node/`              | Node.js LTS via nvm                                                                                       |
| `packages/tmux/`              | `.tmux.conf` (symlinked to `~/.tmux.conf`, OSC 52 clipboard passthrough), `tmux.zsh` `yy` clipboard helper |
| `packages/git/`               | `git.zsh` git aliases and helper functions                                                                |
| `packages/docker/`            | `docker.zsh` Docker Compose aliases                                                                       |
| `packages/ona/`               | `ona.zsh` Ona environment management (oc command + completions; cmux workspace gets the env name)       |
| `packages/claude/`            | Claude Code config: `CLAUDE.md` (linked to `~/.claude/CLAUDE.md`), `output-styles/*` and `skills/*` (one link each into `~/.claude/`). Another repo may link its own `CLAUDE.md` over this one |
| `lib/link.zsh`                | `link_with_backup <src> <dest>`: idempotent symlink with timestamped backup. Use it for links to real files that may hold data |

## Key design decisions

**Symlinks, not copies.** The installer creates symlinks (`ln -sf`) so edits in the repo take effect immediately without re-running the installer. Existing files are backed up with a timestamp suffix.

**zsh.d instead of hard-coded sources.** `.zshrc` sources `~/.config/dotfiles/zsh.d/*.zsh`, so it only loads config of installed packages. Excluding a package later does not remove its old link.

**SSH clipboard via OSC 52.** `packages/tmux/.tmux.conf` enables `allow-passthrough on` and `set-clipboard on` so the escape sequence reaches the host terminal through tmux. `focus-events on` forwards focus events to apps inside tmux.

