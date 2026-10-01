# dotfiles

Personal development environment configuration for macOS and Linux. Covers zsh, tmux, jujutsu, and shell helpers.

## Install

```sh
./install.sh                    # install all packages
./install.sh -o zsh -o jj       # only zsh and jj (plus dependencies, e.g. homebrew)
./install.sh -x node -x tmux    # all packages except node and tmux
DRY_RUN=1 ./install.sh -o node  # print the install plan, do not install
```

Run from any location — the script resolves its own path and uses that as the root for all symlinks.

`-o` and `-x` can be used more than once, but not together. Before it installs, the script lists the requested packages and the dependencies it adds. It exits with an error if:
- a package name is unknown,
- an excluded package (`-x`) is a dependency of a selected package,
- a package named with `-o` is not supported on the current OS.

### Packages

Each directory in `packages/` is one package (`ls packages` lists them). A package can contain:

| File | Purpose |
|---|---|
| `package.conf` | Zsh-sourceable config. `depends=(a b)` lists dependencies; `os=(Darwin)` limits the package to those `uname -s` values (omit for all OSes) |
| `install.sh` | Optional. Runs when the package is installed |
| `*.zsh` | Optional. Linked into `~/.config/dotfiles/zsh.d/`; `.zshrc` sources every file there |

Dependencies install before their dependents. A dependency that is not supported on the current OS is skipped (e.g. `homebrew` on Linux).

| Package | Depends on | Installs |
|---|---|---|
| `homebrew` | — (macOS only) | Homebrew |
| `zsh` | — | oh-my-zsh, spaceship-prompt, zsh-autosuggestions, `~/.zshrc` link |
| `jj` | homebrew, zsh | jj, spaceship-jj, jj config link, `jj.zsh` |
| `fzf` | homebrew | fzf |
| `nvm` | zsh | nvm, `nvm.zsh` (loads nvm) |
| `node` | nvm | Node.js LTS (default) |
| `tmux` | zsh | `~/.tmux.conf` link, `tmux.zsh` |
| `git` | zsh | `git.zsh` |
| `docker` | zsh | `docker.zsh` |
| `ona` | zsh, fzf | `ona.zsh` |

### What gets installed

| Component | macOS | Linux |
|---|---|---|
| oh-my-zsh | curl installer | curl installer |
| spaceship-prompt | git clone | git clone |
| zsh-autosuggestions | git clone | git clone |
| jujutsu (jj) | `brew install jj` | GitHub release tarball |
| spaceship-jj | git clone | git clone |
| fzf | `brew install` | apt/dnf/yum |
| nvm | curl installer | curl installer |
| Node.js (LTS) | nvm | nvm |

Symlinks created:

| Source | Destination |
|---|---|
| `packages/zsh/.zshrc` | `~/.zshrc` |
| `packages/tmux/.tmux.conf` | `~/.tmux.conf` |
| `packages/jj/config.toml` | `~/.config/jj/conf.d/dotfiles.toml` |
| `packages/<name>/*.zsh` | `~/.config/dotfiles/zsh.d/` |

Existing files at those destinations are backed up with a timestamp suffix before the symlink is created.

---

## Zsh

### `.zshrc`

The main entry point. Loads oh-my-zsh with the spaceship theme and the following plugins:

- `git` — git aliases and completions from oh-my-zsh
- `gh` — GitHub CLI completions
- `encode64` — `encode64` / `decode64` helpers
- `zsh-autosuggestions` — inline suggestions as you type
- `spaceship-jj` — jujutsu prompt section for spaceship (only when the `jj` package installed it)

After oh-my-zsh, it sources every file in `~/.config/dotfiles/zsh.d/` (the `*.zsh` files of installed packages). Finally, it sources `~/.zshrc.local` if present, for machine-specific config.

Inline config in `.zshrc`:
- **Spaceship prompt layout**: `user dir host jj git exec_time line_sep exit_code char` — the `jj` section shows only when spaceship-jj is installed; in jj repos `jj.zsh` hides the git section via a `precmd` hook
- **zsh-autosuggestions strategy**: `match_prev_cmd` → `completion` → `history`
- **Less**: `LESS="-FR"` — quit if output fits one screen, pass through raw control characters

### `packages/git/git.zsh`

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

### `packages/jj/jj.zsh`

[Jujutsu](https://github.com/jj-vcs/jj) is a Git-compatible VCS. Shell completions are loaded automatically when `jj` is on `$PATH`.

| Alias | Command | Description |
|---|---|---|
| `jlg` | `jj log` | Show revision log |
| `jnw` | `jj new` | Create a new change |
| `jed` | `jj edit` | Edit a revision |
| `jds` | `jj desc` | Describe (edit commit message) |
| `jpl` | `jj git fetch` | Fetch from Git remote |
| `jpu` | `jj git push` | Push to Git remote |
| `jpua` | function | Prune superseded `osvi/push-*` bookmarks (those with a non-scratch descendant), create push bookmarks for any mutable, un-bookmarked heads, then push everything including deletions. Empty commits with no description are treated as scratch: they don't count as heads for either step |
| `jbk` | `jj bookmark` | Manage bookmarks |
| `jdf` | `jj diff` | Show diff |
| `jst` | `jj st` | Show status |
| `jsq` | `jj squash` | Squash changes |
| `jab` | `jj abandon` | Abandon a change |
| `jrb` | `jj rebase` | Rebase a revision |
| `jrbam` | `jj rebase -b 'heads(mutable() ~ (empty() & description("")))' -o main` | Rebase all mutable heads onto main, excluding empty changes with no description |
| `jcmsg` | `jj commit -m` | Commit working copy with an inline message |

### `packages/jj/config.toml`

Shared jj configuration linked into `~/.config/jj/conf.d/`. The installer also creates an empty `~/.config/jj/config.toml` so that `jj config set --user` writes there instead of overwriting the dotfiles-managed file.

| Setting | Value | Description |
|---|---|---|
| `ui.pager` | `less -FR` | Quit if output fits one screen |
| `remotes.origin.auto-track-bookmarks` | `main\|osvi/*` | Only auto-track `main` and `osvi/` prefixed remote bookmarks |
| `templates.git_push_bookmark` | `osvi/push-<short-change-id>` | Auto-name push bookmarks with `osvi/` prefix |

### `packages/docker/docker.zsh`

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

`packages/tmux/.tmux.conf` is a small config focused on SSH + clipboard integration.

**`allow-passthrough on`**
Lets tmux forward OSC 52 escape sequences from panes to the outer terminal. This lets clipboard writes reach the macOS clipboard over SSH — the sequence travels: app → tmux pane → tmux passthrough → terminal emulator → macOS clipboard.

**`set-clipboard on`**
Tells tmux that the terminal supports the clipboard OSC sequence, so tmux's own clipboard operations also use it.

**`focus-events on`**
Forwards focus-in/focus-out escape sequences to applications inside tmux. This lets apps (e.g. editors) react when you switch back to the terminal.

### `packages/tmux/tmux.zsh` — Shell clipboard helper

| Function | Description |
|---|---|
| `yy` | Copy stdin to the macOS clipboard via OSC 52 |

Pipe any command output to `yy` to copy it to your clipboard through tmux:

```sh
echo "hello world" | yy
cat some-file.txt | yy
git diff | yy
```

