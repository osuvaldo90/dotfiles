# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Workflow

After making changes to the repo, you must consider whether the repo README.md file needs to be updated.

## Installation

```sh
./install.sh
```

Runs from any location — resolves its own path for symlinks. Neovim install is delegated to `neovim/install.sh`. To bootstrap private/machine-specific config, set `EXTRA_DOTFILES_GIST` to a gist URL before running. Claude does not typically need to run this install script unless explicitly asked to.

## Repository structure

| Path                         | Purpose                                                                                                 |
| ---------------------------- | ------------------------------------------------------------------------------------------------------- |
| `install.sh`                 | Top-level installer: oh-my-zsh, spaceship, zsh-autosuggestions, git-town, tmux symlink, zsh symlink     |
| `neovim/install.sh`          | Neovim prerequisites (ripgrep, fd, fzf, lazygit, node, tree-sitter-cli) + nvim install + config symlink |
| `neovim/config/`             | Symlinked to `~/.config/nvim/`. LazyVim-based config                                                    |
| `neovim/config/lua/plugins/` | Plugin overrides — one file per plugin                                                                  |
| `neovim/config/lua/config/`  | LazyVim core config: `options.lua`, `keymaps.lua`, `autocmds.lua`                                       |
| `zsh/.zshrc`                 | Symlinked to `~/.zshrc`. Loads oh-my-zsh, then sources `aliases.zsh`, `exports.zsh`, `functions.zsh`    |
| `tmux/.tmux.conf`            | Symlinked to `~/.tmux.conf`. Focused on OSC 52 clipboard passthrough for SSH                            |

## Key design decisions

**Symlinks, not copies.** The installer creates symlinks (`ln -sf`) so edits in the repo take effect immediately without re-running the installer. Existing files are backed up with a timestamp suffix.

**SSH clipboard via OSC 52.** `neovim/config/lua/config/options.lua` detects `$SSH_TTY` and enables the OSC 52 clipboard provider. `tmux/.tmux.conf` enables `allow-passthrough on` and `set-clipboard on` so the escape sequence reaches the host terminal through tmux.

**LazyVim extras** are declared in `neovim/config/lazyvim.json`. Active extras: `ai.claudecode`, `formatting.prettier`, `lang.typescript`, `linting.eslint`. Claude should not add to this file manually. The user will enable an extra through the Lazy UI which will write to this file.

**TypeScript server selection** (`neovim/config/lua/plugins/typescript.lua`): prefers `tsgo` (Go-based, faster) if available in `$PATH` or `node_modules/.bin/`; falls back to `vtsls`.

**Session restore** (`neovim/config/lua/plugins/persistence.lua`): auto-restores the previous session when nvim opens a directory with no file args, then re-triggers filetype detection so LSP and tree-sitter attach correctly.

## Neovim Lua formatting

Lua files use StyLua. Config is in `neovim/config/stylua.toml`. Run:

```sh
stylua neovim/config/lua/
```
