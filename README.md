# dotfiles

Personal development environment configuration for macOS and Linux. Covers zsh, tmux, and Neovim.

## Install

```sh
./install.sh
```

Run from any location — the script resolves its own path and uses that as the root for all symlinks.

Optionally, set `EXTRA_DOTFILES_GIST` to a URL pointing to a private gist before running. If set, after every other step the installer fetches `~/.zshrc.local` and runs a private `install.sh` from that gist.

### What gets installed

| Component | macOS | Linux |
|---|---|---|
| oh-my-zsh | curl installer | curl installer |
| spaceship-prompt | git clone | git clone |
| zsh-autosuggestions | git clone | git clone |
| git-town | curl installer | curl installer |
| jujutsu (jj) | `brew install jj` | GitHub release tarball |
| spaceship-jj | git clone | git clone |
| Neovim | `brew install neovim` | GitHub release tarball → `/opt` |
| ripgrep | `brew install` | apt/dnf/yum |
| fd | `brew install` | apt/dnf/yum |
| fzf | `brew install` | apt/dnf/yum |
| lazygit | `brew install` | GitHub release tarball |
| nvm | curl installer | curl installer |
| Node.js (LTS) | nvm | nvm |
| tree-sitter-cli | `npm install -g` | `npm install -g` |

Build tools (Xcode CLT on macOS, `build-essential`/`gcc` on Linux) are installed automatically so tree-sitter parsers can compile.

Symlinks created:

| Source | Destination |
|---|---|
| `zsh/.zshrc` | `~/.zshrc` |
| `tmux/.tmux.conf` | `~/.tmux.conf` |
| `neovim/config/` | `~/.config/nvim/` |
| `jujutsu/config.toml` | `~/.config/jj/conf.d/dotfiles.toml` |

Existing files at those destinations are backed up with a timestamp suffix before the symlink is created.

---

## Testing

The install script can be tested end-to-end inside a Docker container without touching the host machine.

```sh
./test.sh
```

This builds an Ubuntu image (`Dockerfile`) with the minimal bootstrap prerequisites (git, curl, zsh, sudo), mounts the local repo into the container, runs `install.sh`, and then runs `test-verify.sh` to check every installed component.

`test-verify.sh` checks:
- oh-my-zsh directory, spaceship symlink, zsh-autosuggestions directory
- git-town binary and its four global git config values
- jujutsu (jj) binary
- nvm, node, npm versions and the `lts/*` default alias
- ripgrep, fd, fzf, lazygit, tree-sitter-cli binaries
- `~/.tmux.conf`, `~/.zshrc`, `~/.config/nvim` symlinks

Docker layer caching makes repeat runs fast — only the `docker run` step re-executes on subsequent calls.

---

## Zsh

### `.zshrc`

The main entry point. Loads oh-my-zsh with the spaceship theme and the following plugins:

- `git` — git aliases and completions from oh-my-zsh
- `gh` — GitHub CLI completions
- `encode64` — `encode64` / `decode64` helpers
- `zsh-autosuggestions` — inline suggestions as you type
- `spaceship-jj` — jujutsu prompt section for spaceship

After oh-my-zsh, it sources per-tool zsh files from their respective top-level directories (e.g., `git/git.zsh`, `docker/docker.zsh`). Finally, it sources `~/.zshrc.local` if present, for machine-specific config.

Inline config in `.zshrc`:
- **Spaceship prompt layout**: `user dir host jj git exec_time line_sep exit_code char` — in jj repos the git section is automatically hidden via a `precmd` hook
- **zsh-autosuggestions strategy**: `match_prev_cmd` → `completion` → `history`
- **Editor**: `EDITOR` and `VISUAL` set to `nvim`
- **Less**: `LESS="-FR"` — quit if output fits one screen, pass through raw control characters

### `git/git.zsh`

#### Core shortcuts

| Alias | Command | Description |
|---|---|---|
| `co` | `git checkout` | Checkout a branch |
| `com` | `git checkout <main-branch>` | Checkout the repo's main branch |
| `st` | `git status -s` | Short status |
| `fh` | `git commit --amend --no-edit` | Fixup HEAD (amend without editing message) |
| `cf` | `git commit --fixup` | Create a fixup commit for a given ref |
| `pu` | `git push --set-upstream origin` | Push and set upstream |
| `pf` | `git push --force-with-lease` | Safe force push |
| `ga.` | `git add .` | Stage all changes |
| `cotmp` | Delete and recreate `tmp` branch | Quickly reset a scratch branch |

#### Log views

All log aliases use a graph format with commit subject, hash, date, author, and decorations.

| Alias | Description |
|---|---|
| `lg` | Graph log with relative dates |
| `lgf` | Graph log, first-parent only (linear history) |
| `lgb` | Graph log from main branch to HEAD (current branch only) |
| `lgd` | Graph log with absolute local dates |
| `lgt` | Interactive log via `tv git-log` |

#### Compound workflows

| Alias | Expands to | Description |
|---|---|---|
| `newpr` | `re <main> && pu && gh pr create` | Rebase onto main, push, open PR |
| `rem` | `re_remote <main>` | Fetch and rebase onto remote main |
| `reom` | `reo origin/<main>` | Rebase --onto remote main |
| `rpf` | `rem && pf` | Rebase onto remote main then force-push |
| `frpf` | `fh && rem && pf` | Amend HEAD, rebase onto remote main, force-push |

#### Helper functions

Functions for git operations that stash, do something, and unstash — keeping the working tree clean across branch switches.

**`stash` / `unstash`** — `stash` runs `git stash -u` (including untracked files) and returns the pre-stash count. `unstash` pops only if the stash count actually grew.

**`pl`** — Pull with rebase, safely stashing and restoring any in-progress work.

**`ub <branch>`** — Update (pull --rebase) another branch without leaving the current one.

**`re <branch>`** — Rebase the current branch onto a local branch after first updating that branch.

**`re_remote <branch>`** — Like `re`, but fetches from origin instead of checking out locally.

**`reo <onto> <upstream>`** — `git rebase --onto` variant with local update of the onto branch.

**`rei <branch>`** — Interactive rebase onto a local branch (same stash/update pattern).

**`gsts [stash-ref]`** — Show the full diff of a stash entry, including tracked changes and untracked file snapshot (`^3`).

### `git-town/git-town.zsh`

[git-town](https://www.git-town.com/) manages branch stacks and syncing. Configured with:
- Main branch: `main`
- GitHub connector: `gh`
- Sync strategy: rebase
- Tags: not synced

| Alias | Command | Description |
|---|---|---|
| `gt` | `git town` | Base command |
| `gs` | `git town sync --no-push` | Sync current branch (no push) |
| `gsr` | `git town sync` | Sync and push |
| `gsa` | `git town sync --all --no-push` | Sync all branches |
| `gsar` | `git town sync --all` | Sync all branches and push |
| `ft` | `git town hack` | Create a new feature branch |
| `pr` | `git town propose` | Open a PR for the current branch |
| `ap` | `git town append` | Append a child branch |
| `sw` | `git town switch` | Interactively switch branches |
| `gtc` | `git town continue` | Continue after resolving conflicts |
| `gts` | `git town skip` | Skip a conflicting sync step |
| `gtb` | `git town branch` | Show branch lineage |

### `jujutsu/jujutsu.zsh`

[Jujutsu](https://github.com/jj-vcs/jj) is a Git-compatible VCS. Shell completions are loaded automatically when `jj` is on `$PATH`.

| Alias | Command | Description |
|---|---|---|
| `jlg` | `jj log` | Show revision log |
| `jne` | `jj new` | Create a new change |
| `jed` | `jj edit` | Edit a revision |
| `jde` | `jj desc` | Describe (edit commit message) |
| `jpl` | `jj git fetch` | Fetch from Git remote |
| `jpu` | `jj git push` | Push to Git remote |
| `jpua` | `jj git push --allow-empty-description -c '...'` | Push all mutable, non-empty, non-bookmarked changes |
| `jbk` | `jj bookmark` | Manage bookmarks |
| `jdf` | `jj diff` | Show diff |
| `jst` | `jj st` | Show status |
| `jsq` | `jj squash` | Squash changes |
| `jab` | `jj abandon` | Abandon a change |
| `jrb` | `jj rebase` | Rebase a revision |
| `jcmsg` | `jj commit -m` | Commit working copy with an inline message |

### `jujutsu/config.toml`

Shared jj configuration linked into `~/.config/jj/conf.d/`. The installer also creates an empty `~/.config/jj/config.toml` so that `jj config set --user` writes there instead of overwriting the dotfiles-managed file.

| Setting | Value | Description |
|---|---|---|
| `ui.pager` | `less -FR` | Quit if output fits one screen |
| `remotes.origin.auto-track-bookmarks` | `main\|osvi/*` | Only auto-track `main` and `osvi/` prefixed remote bookmarks |
| `templates.git_push_bookmark` | `osvi/push-<short-change-id>` | Auto-name push bookmarks with `osvi/` prefix |

### `docker/docker.zsh`

| Alias | Command |
|---|---|
| `dc` | `docker compose` |
| `dcu` | `docker compose up` |
| `dcud` | `docker compose up -d` |
| `dcd` | `docker compose down` |
| `dcl` | `docker compose logs` |
| `dcp` | `docker compose ps` |
| `dcr` | `docker compose restart` |
| `dcrm` | `docker compose rm` |
| `dcs` | `docker compose stop` |
| `dcst` | `docker compose start` |
| `dct` | `docker compose top` |
| `dcuw` | `docker compose up --wait` |

---

## Tmux

`tmux/.tmux.conf` is a small config focused on SSH + clipboard integration.

**`allow-passthrough on`**
Lets tmux forward OSC 52 escape sequences from panes to the outer terminal. This is what enables Neovim's yank to reach the macOS clipboard when editing over SSH — the sequence travels: Neovim → tmux pane → tmux passthrough → terminal emulator → macOS clipboard.

**`set-clipboard on`**
Tells tmux that the terminal supports the clipboard OSC sequence, so tmux's own clipboard operations also use it.

---

## Neovim

Built on [LazyVim](https://www.lazyvim.org/) with a small set of overrides and additions.

### LazyVim extras enabled (`lazyvim.json`)

| Extra | What it adds |
|---|---|
| `ai.claudecode` | Claude Code integration (see below) |
| `ai.copilot` | GitHub Copilot completions |
| `coding.mini-surround` | Add/delete/replace surroundings (brackets, quotes, etc.) |
| `formatting.prettier` | Prettier as the formatter for JS/TS/CSS/JSON/etc |
| `lang.typescript` | TypeScript LSP, treesitter, and tooling |
| `linting.eslint` | ESLint via `nvim-lint` |

### Plugin customizations (`lua/plugins/`)

**`bufferline.lua`**
Sets `always_show_bufferline = true` so the buffer tab bar is visible even with a single buffer open.

**`claudecode.lua`**
Configures [claudecode.nvim](https://github.com/coder/claudecode.nvim) to launch Claude Code with `--permission-mode auto`. Also adds a `WinEnter` autocmd that redraws terminal windows to fix cursor misalignment caused by TUI apps.

**`colorscheme.lua`**
Installs [zenbones.nvim](https://github.com/zenbones-theme/zenbones.nvim) (with Lush dependency) and sets the `nordbones` colorscheme.

**`formatting.lua`**
Configures [conform.nvim](https://github.com/stevearc/conform.nvim) with a priority-ordered formatter chain for JS/TS/CSS/JSON/GraphQL files:
1. **oxfmt** — active when `.oxfmtrc.json` or `.oxfmtrc.jsonc` is found. Resolves binary from local `node_modules`, global `$PATH`, or `npx` fallback.
2. **biome** — active when `biome.json` or `biome.jsonc` is found.
3. **prettier** — fallback, provided by the LazyVim formatting extra.

**`graphql.lua`**
Adds GraphQL support: ensures the treesitter `graphql` parser is installed and configures the GraphQL language server (requires `graphql-language-service-cli` and a `.graphqlrc.yml` or `graphql.config.ts` in the project root).

**`lualine.lua`**
Replaces the default LazyVim status line path component with a non-truncating version that shows the path relative to the current working directory.

**`scrollbar.lua`**
Configures [satellite.nvim](https://github.com/lewis6991/satellite.nvim) to show a scrollbar with cursor position, diagnostics, and gitsigns indicators.

**`snacks.lua`**
Placeholder for [snacks.nvim](https://github.com/folke/snacks.nvim) picker overrides. Hidden/ignored file search is currently disabled (defaults to LazyVim behavior).

**`treesitter-context.lua`**
Enables [nvim-treesitter-context](https://github.com/nvim-treesitter/nvim-treesitter-context) with up to 13 context lines pinned at the top of the window.

**`typescript.lua`**
Auto-selects the TypeScript language server based on what's available in the project:
- If `tsgo` is on `$PATH` or in `node_modules/.bin/`, use `tsgo` (the faster Go-based TS server).
- Otherwise, fall back to `vtsls`.

Also adds [typescript-explorer.nvim](https://github.com/osuvaldo90/typescript-explorer.nvim) for TypeScript type exploration.

### `lua/config/keymaps.lua` — Custom keymaps

| Key | Mode | Description |
|---|---|---|
| `<leader>gc` | n, v | Copy GitHub URL of current file/selection to clipboard |
| `<leader>bc` | n | Copy buffer relative path to clipboard |
| `<M-BS>` | i | Delete word backward (Alt+Backspace) |
| `<leader>bw` | n | Toggle line wrapping |
| `<leader>fG` | n | Find git changed files via Snacks picker |

### `lua/config/autocmds.lua` — Custom autocmds

- **Prose wrapping**: Sets `wrap`, `linebreak`, and `textwidth=100` for markdown, text, log, and gitcommit files.
- **Buffer auto-reload**: Runs `checktime` on `BufEnter` and `CursorHold` to reload buffers changed on disk (supplements LazyVim's `FocusGained` handler for tmux/Claude Code scenarios).

### `lua/config/options.lua` — SSH clipboard

When Neovim detects it's running over SSH (`$SSH_TTY` is set), LazyVim normally disables clipboard integration. This override enables it by configuring the clipboard to use the OSC 52 provider, which encodes clipboard content in an escape sequence and sends it to the terminal. Combined with `allow-passthrough on` in tmux, yanks reach the macOS clipboard even in deeply nested SSH+tmux sessions.
