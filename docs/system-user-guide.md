# System User Guide

A beginner-first guide for using this setup effectively on day one. This document explains how the major pieces fit together so you know where to act, where to navigate, and which tool should own each kind of work.

## Mental Model

This system has four main layers:

1. **Desktop layer**: Hyprland on `carbon`, macOS desktop on `macmini`
2. **Terminal layer**: Ghostty
3. **Terminal workspace layer**: tmux
4. **Editor layer**: Emacs

The rule of thumb is:

| If you want to move between... | Use... |
|-------------------------------|--------|
| top-level application windows | Hyprland or macOS window switching |
| desktop workspaces | Hyprland workspaces |
| terminal tabs | Ghostty tabs |
| terminal panes and long-lived shell sessions | tmux |
| files, buffers, and editor workspaces | Emacs |

Do not force one tool to do another tool's job:
- do not use Ghostty tabs as a substitute for tmux sessions
- do not use tmux as a substitute for desktop workspaces
- do not use extra Emacs frames as your main project-switching model

## Platform Overview

| Host | Platform | Main desktop behavior |
|------|----------|-----------------------|
| `carbon` | NixOS | Hyprland desktop with Ghostty, tmux, Emacs, Firefox, VS Code |
| `macmini` | macOS | Native macOS desktop with Ghostty, tmux, Emacs, Firefox, VS Code, Karabiner remap |

Shared expectations:
- application shortcuts use `Ctrl`
- terminal work starts in Ghostty and usually lives in tmux
- Emacs is the primary editor

## First-Day Workflow

### 1. Open a terminal

On `carbon`:
- press `Super+Return` to open Ghostty

On `macmini`:
- open Ghostty from the app launcher (installed via Homebrew cask — `darwin/common/homebrew.nix`)
- if fresh setup: run `just darwin-switch` first to install Ghostty and all other Homebrew casks
- Karabiner-Elements will need Accessibility and Input Monitoring permissions granted manually in System Settings > Privacy & Security

### 2. Start tmux

Inside Ghostty:

```bash
tmux
```

If you already use named sessions, attach to the right one instead.

### 3. Decide your workspace level

Use this decision table:

| Need | Best tool |
|------|-----------|
| separate app windows | Hyprland/macOS |
| a quick throwaway terminal | Ghostty tab |
| persistent terminal work with panes/logging | tmux |
| coding, writing, search, LSP, git UI | Emacs |

### 4. Open your main editor

From a shell:

```bash
emacsclient -c
```

Then use `C-c p p` to switch into a project and let Emacs restore the IDE layout.

## Moving Around The System

### macOS (macmini)

macOS uses native desktop management instead of Hyprland:
- use Mission Control (`Ctrl+Up`) and Spaces for virtual desktops
- use `Cmd+Tab` for app switching (remapped to `Ctrl+Tab` by Karabiner)
- use Raycast for app launching and productivity shortcuts
- use `drs` alias to rebuild the nix-darwin config: `drs` (equivalent of `nrs` on Linux)
- use `drt` alias to check config without switching: `drt`

### Hyprland

Hyprland owns desktop-level movement on `carbon`.

| Key | Action |
|-----|--------|
| `Super+Return` | New terminal |
| `Super+D` | Launcher |
| `Super+1` .. `Super+0` | Go to workspace |
| `Super+Shift+1` .. `Super+Shift+0` | Move window to workspace |
| `Super+,` / `Super+.` | Previous / next workspace |
| `Alt+Tab` / `Alt+Shift+Tab` | Cycle windows |
| `Ctrl+Alt+B/F/P/N` | Focus window left / right / up / down |
| `Ctrl+Alt+Shift+B/F/P/N` | Move window left / right / up / down |
| `Super+\`` | Toggle dropdown terminal |
| `Super+F` | Fullscreen |
| `Super+Space` | Toggle floating |
| `Super+L` | Lock |

### Ghostty

Ghostty is the terminal app. Use tabs lightly.

| Key | Action |
|-----|--------|
| `Ctrl+Shift+T` | New tab |
| `Ctrl+Tab` / `Ctrl+Shift+Tab` | Next / previous tab |
| `Ctrl+Shift+W` | Close current tab or surface |
| `Ctrl+Shift+C` / `Ctrl+Shift+V` | Copy / paste |
| `Ctrl+Shift+Up` / `Ctrl+Shift+Down` | Jump between prompts |

Use Ghostty tabs for distinct top-level contexts:
- local work
- remote shell
- production console

If you are splitting a task into panes or want persistence, switch to tmux.

### tmux

tmux owns persistent terminal layouts.

| Key | Action |
|-----|--------|
| `Ctrl+A` | Prefix |
| `Prefix + c` | New window |
| `Prefix + |` | Split vertically into left/right panes |
| `Prefix + -` | Split horizontally into top/bottom panes |
| `Alt+arrows` | Move between panes |
| `Shift+Left` / `Shift+Right` | Previous / next tmux window |
| `Ctrl+Shift+arrows` | Resize pane |
| `Prefix + f` | Fuzzy-find sessions/windows/panes |
| `Prefix + Space` | Copy visible URLs, paths, hashes, IPs |

Use tmux windows for broad task separation:
- editor shell
- tests
- logs
- infra work

Use tmux panes for related concurrent views:
- shell plus watcher
- app logs plus shell
- shell plus docs or second REPL

### Emacs

Emacs owns file editing, project search, and editor workspaces.

| Key | Action |
|-----|--------|
| `C-x C-f` | Open file |
| `C-x b` | Switch buffer |
| `C-c p p` | Switch project |
| `C-c p f` | Find file in project |
| `M-s g` | Project search |
| `M-.` / `M-?` | Definition / references |
| `C-c t` | Toggle file tree |
| `C-c i` | Toggle symbol outline |
| `C-c v` / `C-c V` | Toggle / maximize terminal panel |
| `Ctrl+PageUp` / `Ctrl+PageDown` | Previous / next editor tab |
| `C-c w s` | Switch Emacs workspace |

Use:
- buffers for open files and views
- windows for splits inside the current frame
- tabs for quick file movement
- workspaces for separate projects or contexts

## Recommended Daily Patterns

### Pattern: coding in one project

1. Open Ghostty
2. Start tmux
3. Open `emacsclient -c`
4. In Emacs, `C-c p p` into the project
5. Keep tests/logs either in tmux or the Emacs terminal panel depending on how tightly they relate to your current file

### Pattern: infrastructure or operations work

1. Open Ghostty
2. Start tmux
3. Use tmux windows for shell, logs, and remote sessions
4. Use `tdev`, `tops`, or `tmon` if one matches the task
5. Open Emacs only if you need structured editing or repo-wide search/refactoring

### Pattern: quick check without disturbing your main layout

On `carbon`, use the Hyprland dropdown terminal with `Super+\`` for:
- one-off git status
- package/version checks
- a quick `journalctl`, `kubectl`, or `rg`

On `macmini`, use a Ghostty tab (`Ctrl+Shift+T`) for the same purpose — there is no dropdown terminal on macOS.

### Pattern: machine-wide utility commands from any directory

Use `ujust` when you want the host-level utility `justfile` instead of a repo-local one.

Examples:
- `ujust now`
- `ujust weather NYC`
- `ujust ports`
- `ujust ocr-shot`
- `ujust doctor`
- `ujust host-info`

For nixcfg specifically, the universal layer also exposes:
- `ujust nixcfg-check`
- `ujust nixcfg-update`
- `ujust nixcfg-switch`
- `ujust nixcfg-home-switch`
- `ujust rebuild`
- `ujust rollback`

For host operations, it also exposes:
- `ujust tailscale-status`
- `ujust tailscale-up`
- `ujust bootstrap`
- `ujust post-switch`

Use plain `just` when you want the current repository's own recipes.

### Pattern: signed commits and terminal secrets

1. Check available signing keys with `gpgkeys`
2. Confirm git signing state with `just git-signing-status` or `task signing-status`
3. Use `git cs -m "message"` for a signed commit
4. Use `rbw login` and `rbw get <item>` for terminal secret retrieval

### Pattern: quick OCR or document extraction (Linux only)

1. Press `Super+Ctrl+O` to OCR a selected screen region
2. Use `ocrimg file.png` for images or `ocrpdf file.pdf 2` for a PDF page
3. Open PDFs in `zathura` when you want a keyboard-friendly viewer

Note: OCR functions are not yet available on macOS. See `docs/mac-parity-todo.md` for planned alternatives.

## Where To Learn More

- CLI stack: [home/features/cli/README.md](../home/features/cli/README.md)
- Desktop stack: [home/features/desktop/README.md](../home/features/desktop/README.md)
- Editors: [home/features/editors/README.md](../home/features/editors/README.md)
- Deep Emacs guide: [home/features/editors/GUIDE.md](../home/features/editors/GUIDE.md)
- Hyprland deep dive: [hyprland-configuration.md](hyprland-configuration.md)
- Keyboard strategy: [keyboard-layout-strategy.md](keyboard-layout-strategy.md)
- Shortcut conflicts to resolve later: [keyboard-shortcut-conflicts.md](keyboard-shortcut-conflicts.md)
