# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Workflow

After making changes to the repo, ALWAYS run `./test.sh` to verify your changes and iterate until it succeeds — no exceptions. If `docker` is not available, report that clearly to the user rather than skipping tests silently. If you add/remove a tool or change a tool configuration you must also update `test-verify.sh`. When a tool is added/removed or a tool configuration is changed you must update the README.md file.

## Installation

```sh
./install.sh
```

Runs from any location — resolves its own path for symlinks. Neovim install is delegated to `neovim/install.sh`. To bootstrap private/machine-specific config, set `EXTRA_DOTFILES_GIST` to a gist URL before running; the top-level `install.sh` runs that gist bootstrap **last**, after all other installers. Claude does not typically need to run this install script unless explicitly asked to.

## Repository structure

| Path                         | Purpose                                                                                                 |
| ---------------------------- | ------------------------------------------------------------------------------------------------------- |
| `install.sh`                 | Top-level installer: delegates to per-tool installers in order; optional `EXTRA_DOTFILES_GIST` step last |
| `macos/install.sh`           | macOS-specific setup (Homebrew)                                                                         |
| `zsh/install.sh`             | oh-my-zsh, spaceship-prompt, zsh-autosuggestions, `~/.zshrc` symlink                                    |
| `git-town/install.sh`        | git-town binary + global git config                                                                     |
| `jujutsu/install.sh`         | jj binary (brew/GitHub release), config symlink, spaceship-jj prompt section                            |
| `jujutsu/config.toml`        | Shared jj config (linked to `~/.config/jj/conf.d/dotfiles.toml`): auto-tracks `main` and `osvi/*` bookmarks, push bookmark prefix `osvi/` |
| `node/install.sh`            | nvm + Node.js LTS                                                                                       |
| `neovim/install.sh`          | Neovim prerequisites (ripgrep, fd, fzf, lazygit, tree-sitter-cli) + nvim install + config symlink       |
| `neovim/config/`             | Symlinked to `~/.config/nvim/`. LazyVim-based config                                                    |
| `neovim/config/lua/plugins/` | Plugin overrides — one file per plugin                                                                  |
| `neovim/config/lua/config/`  | LazyVim core config: `options.lua`, `keymaps.lua`, `autocmds.lua`                                       |
| `tmux/install.sh`            | Symlinks `~/.tmux.conf`                                                                                 |
| `zsh/.zshrc`                 | Symlinked to `~/.zshrc`. Loads oh-my-zsh, then sources per-tool zsh files                               |
| `git/git.zsh`                | Git aliases and helper functions (stash/rebase workflows)                                               |
| `git-town/git-town.zsh`      | Git Town aliases                                                                                        |
| `jujutsu/jujutsu.zsh`        | Jujutsu aliases and shell completions                                                                   |
| `docker/docker.zsh`           | Docker Compose aliases                                                                                  |
| `gitpod/gitpod.zsh`           | Gitpod environment management (oc command + completions)                                                |
| `tmux/.tmux.conf`            | Symlinked to `~/.tmux.conf`. Focused on OSC 52 clipboard passthrough for SSH                            |
| `tmux/tmux.zsh`              | `yy` function: pipe command output to macOS clipboard via OSC 52 (`echo hello \| yy`)                   |

## Key design decisions

**Symlinks, not copies.** The installer creates symlinks (`ln -sf`) so edits in the repo take effect immediately without re-running the installer. Existing files are backed up with a timestamp suffix.

**SSH clipboard via OSC 52.** `neovim/config/lua/config/options.lua` detects `$SSH_TTY` and enables the OSC 52 clipboard provider. `tmux/.tmux.conf` enables `allow-passthrough on` and `set-clipboard on` so the escape sequence reaches the host terminal through tmux.

**LazyVim extras** are declared in `neovim/config/lazyvim.json`. Active extras: `ai.claudecode`, `ai.copilot`, `coding.mini-surround`, `formatting.prettier`, `lang.typescript`, `linting.eslint`. Claude should not add to this file manually. The user will enable an extra through the Lazy UI which will write to this file.

**TypeScript server selection** (`neovim/config/lua/plugins/typescript.lua`): prefers `tsgo` (Go-based, faster) if available in `$PATH` or `node_modules/.bin/`; falls back to `vtsls`.

**Session restore** (`neovim/config/lua/plugins/persistence.lua`): currently disabled. When enabled, auto-restores the previous session when nvim opens a directory with no file args, then re-triggers filetype detection so LSP and tree-sitter attach correctly.

**Claude Code** (`neovim/config/lua/plugins/claudecode.lua`): launches Claude Code with `--permission-mode auto` and adds a terminal redraw workaround for TUI cursor positioning.

## Neovim Lua formatting

Lua files use StyLua. Config is in `neovim/config/stylua.toml`. Run:

```sh
stylua neovim/config/lua/
```
