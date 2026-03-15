# CLI Features

Command-line tools, shell configuration, terminal behavior, and terminal multiplexing shared across NixOS and macOS.

## Start Here

Use the CLI stack in layers:

1. **Ghostty** is the terminal app you open first.
2. **tmux** is where long-lived terminal work should usually happen.
3. **zsh** is the shell inside each tmux pane.
4. **CLI apps** are chosen based on the job: search, file management, git, JSON, monitoring, or project scaffolding.

Recommended daily flow:
- Open Ghostty.
- Start or attach tmux.
- Use tmux windows for major tasks and tmux panes for closely related subtasks.
- Use shell history, fuzzy search, and aliases to stay fast.

## What To Use When

| Tool | Use it for | Prefer it over |
|------|------------|----------------|
| Ghostty | Opening terminals, using tabs, clipboard, prompt navigation, quick scratch sessions | Running multiple unrelated tasks in plain tabs forever |
| tmux | Persistent sessions, multi-pane layouts, recoverable work, logging, remote sessions | Keeping important work only in Ghostty tabs |
| zsh | Everyday shell work, aliases, functions, completion, prompt | Raw POSIX shell interaction |
| Atuin | Searching command history semantically | Scrolling through shell history manually |
| fzf | Fuzzy-picking files, history, branches, processes | Grepping and retyping long lists |
| Yazi | Fast file management in the terminal | Repetitive `mv`/`cp`/`rm` loops for many files |
| lazygit | Git staging, history, branch work, rebases | Memorizing every intermediate git subcommand |
| glow | Reading markdown in-terminal | Raw markdown for longer docs |
| pueue | Backgrounding long-running commands you want to monitor later | Leaving one shell blocked for hours |

## Movement And Navigation

### Shell line editing (zsh)

The shell uses Emacs-style editing.

| Key | Action |
|-----|--------|
| `Ctrl+A` | Move to start of line |
| `Ctrl+E` | Move to end of line |
| `Ctrl+K` | Kill to end of line |
| `Ctrl+U` | Kill to start of line |
| `Ctrl+W` | Delete previous word |
| `Ctrl+Y` | Yank last killed text |
| `Ctrl+R` | History search |

If you are inside tmux, `Ctrl+A` is tmux prefix first. Press `Ctrl+A Ctrl+A` to send a literal `Ctrl+A` to the shell.

### Ghostty

Ghostty is the terminal application, not the session manager.

| Key | Action |
|-----|--------|
| `Ctrl+Shift+T` | New tab |
| `Ctrl+Tab` | Next tab |
| `Ctrl+Shift+Tab` | Previous tab |
| `Ctrl+Shift+W` | Close current surface/tab |
| `Ctrl+Shift+C` | Copy |
| `Ctrl+Shift+V` | Paste |
| `Ctrl+=` / `Ctrl+-` / `Ctrl+0` | Increase / decrease / reset font size |
| `Ctrl+Shift+Up` / `Ctrl+Shift+Down` | Jump between shell prompts |

Ghostty tabs are best for separate top-level contexts, such as one tab for local work and one for SSH. Use tmux inside a tab when you need panes, persistence, or logging.

### tmux

tmux is the main workspace manager for terminal work.

| Key | Action |
|-----|--------|
| `Ctrl+A` | Prefix |
| `Prefix + c` | New window |
| `Prefix + |` | Split left/right |
| `Prefix + -` | Split top/bottom |
| `Alt+Left/Right/Up/Down` | Move between panes |
| `Shift+Left` / `Shift+Right` | Previous / next window |
| `Ctrl+Shift+Left/Right/Up/Down` | Resize current pane |
| `Prefix + f` | Fuzzy-find sessions, windows, panes |
| `Prefix + Space` | Highlight visible URLs/paths/hashes to copy |
| `Prefix + r` | Reload tmux config |

Use tmux windows for distinct tasks:
- one window for coding
- one for tests or logs
- one for infra or remote work

Use tmux panes for tightly related views inside one task:
- editor shell + test runner
- logs + interactive shell
- app + database shell

### Yazi

Use `y` when you want a terminal file manager that returns you to the last directory on quit.

| Key | Action |
|-----|--------|
| Arrow keys / `hjkl` | Move |
| `Enter` | Open file or enter directory |
| `Space` | Select |
| `Tab` | Switch tab |
| `t` | New tab |
| `z` | Jump via zoxide |
| `/` | Search |
| `f` | Filter |
| `.` | Toggle hidden files |
| `q` | Quit |

## Core Daily Tools

### Shell helpers

| Command | Purpose |
|---------|---------|
| `z <partial>` | Jump to a frequently used directory |
| `mkcd <dir>` | Make a directory and enter it |
| `mkproject <name> [python|typescript|rust|go|terraform]` | Create a project scaffold with git, direnv, and a flake template |
| `serve [port]` | Start a quick static file server |
| `y` | Open Yazi and `cd` to the last visited directory |
| `md <file>` | Render markdown with glow |
| `ujust <recipe>` | Run the universal host-level `justfile` from any directory |

### History and fuzzy search

| Tool | Usage |
|------|-------|
| Atuin | Use shell history search instead of raw up-arrow hunting |
| fzf | Used by integrations and useful for custom shell pipelines |
| `ripgrep` / `grep` | Fast recursive search |
| `fd` | Fast file finding when you want file names instead of content matches |

### Git and repo work

| Command | Purpose |
|---------|---------|
| `g`, `gs`, `ga`, `gc`, `gp`, `gl`, `gd`, `gco`, `gb` | Git aliases |
| `glog` | Compact graph view |
| `lg` | lazygit TUI |
| `delta` | Syntax-aware git diff pager |

### Universal justfile

Use `ujust` for commands that should work from any directory on the machine, instead of only inside a specific repo.

Examples:
- `ujust now`
- `ujust weather NYC`
- `ujust ports`
- `ujust ocr-shot`
- `ujust cliphist`
- `ujust nixcfg-check`
- `ujust nixcfg-switch`
- `ujust nixcfg-update`
- `ujust doctor`
- `ujust host-info`
- `ujust tailscale-status`
- `ujust tailscale-up`
- `ujust rebuild`
- `ujust rollback`

Use plain `just` when you want the current project's nearest `justfile`.

### Background and monitoring

| Command | Purpose |
|---------|---------|
| `pqa '<cmd>'` | Queue a long-running task |
| `pqs` | See queue status |
| `pql` | View task logs |
| `tops` | Open tmux ops layout |
| `tmon` | Open tmux monitoring layout |
| `top` | Launch `btop` |
| `ps` | Launch `procs` |
| `df` | Launch `duf` |
| `du` | Launch `dust` |

## Modern Replacements And Power Tools

### Replacements you can use by habit

| Traditional | Actual tool |
|-------------|-------------|
| `grep` | `ripgrep` |
| `top` | `btop` |
| `ps` | `procs` |
| `df` | `duf` |
| `du` | `dust` |
| `ping` | `prettyping` |
| `watch` | `viddy` |
| `dig` | `doggo` |
| `diff` | `difftastic` |

### Tools worth learning on purpose

| Tool | Use case |
|------|----------|
| `json` (`fx`) | Explore and transform JSON interactively |
| `xh` / `http` | Human-friendly HTTP client |
| `choose` | Pull columns from tabular output without awk gymnastics |
| `sd` | Simple search and replace |
| `hyperfine` / `bench` | Compare command speed |
| `entr`, `watchexec` | Re-run commands when files change |
| `comma` | Run a nixpkgs binary without adding it permanently |
| `nix-tree`, `nix-diff`, `nvd`, `nurl` | Nix debugging and inspection |
| `sshs` | Browse SSH connections from config |

## Tmux Session Helpers

The shell includes a few fast tmux layouts:

| Function | Layout |
|----------|--------|
| `tdev` | Editor shell + extra shell + git log pane |
| `tops` | `btop` plus two support shells |
| `tmon` | Four-pane monitoring/log layout |

Use these when you want a ready-made starting point instead of manually splitting panes.

## Design Notes

- Ghostty has no auto-logging; tmux logging fills that gap.
- tmux sessions auto-save every 15 minutes and restore on startup.
- tmux copy mode is `vi` only inside copy mode; shell editing stays Emacs-style.
- The shell is intentionally Emacs-first, matching the wider keyboard strategy across the repo.

See [ADR-002](../../../docs/adr/ADR-002-shell-and-terminal-choices.md), [ADR-008](../../../docs/adr/ADR-008-tmux-integration.md), and [ADR-010](../../../docs/adr/ADR-010-shell-plugin-management.md).
