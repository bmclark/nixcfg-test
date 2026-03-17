# System User Guide

A beginner-first guide for using this setup effectively on day one. This document explains how the major pieces fit together so you know where to act, where to navigate, and which tool should own each kind of work.

## Mental Model

This system has four main layers:

1. **Desktop layer**: Hyprland on `maverick`, Aerospace on `iceman`
2. **Terminal layer**: Ghostty
3. **Terminal workspace layer**: tmux
4. **Editor layer**: Emacs

The rule of thumb is:

| If you want to move between... | Use... |
|-------------------------------|--------|
| top-level application windows | Hyprland or Aerospace |
| desktop workspaces | Hyper workspaces |
| terminal tabs | Ghostty tabs |
| terminal panes and long-lived shell sessions | tmux |
| files, buffers, and editor workspaces | Emacs |

Do not force one tool to do another tool's job:
- do not use Ghostty tabs as a substitute for tmux sessions
- do not use tmux as a substitute for desktop workspaces
- do not use extra Emacs frames as your main project-switching model

## Keyboard Model

This setup uses two different physical modifiers:

| What docs say | Physical key you press | Use |
|---------------|------------------------|-----|
| `Ctrl` | `CapsLock` | shell, Emacs, Ghostty, tmux, Linux app shortcuts |
| `Hyper` | physical `Ctrl` | Hyprland / Aerospace window management |

All shortcut tables below prefer the physical key sequence you should actually press.

Platform-native macOS shortcuts stay native:

- GUI app copy/paste is still `Cmd+C/V/X`
- `Cmd+Tab` still works natively
- quit is still `Cmd+Q`

## Learn These First

If you only memorize a few things, start here:

| Physical key | Action | Why it matters |
|--------------|--------|----------------|
| `Ctrl+Return` | Open Ghostty | Fastest way to enter the whole stack |
| `Ctrl+D` | Open the launcher | Start apps without hunting through menus |
| `Ctrl+1` .. `Ctrl+0` | Go to workspace 1..10 | Main desktop navigation |
| `Ctrl+Shift+1` .. `Ctrl+Shift+0` | Move a window to workspace 1..10 | Main desktop organization tool |
| `Ctrl+\`` | Scratch terminal / scratch workspace | Quick temporary work area |
| `CapsLock+]` | `Ctrl+]` | Primary tmux prefix |
| `CapsLock+A` | `Ctrl+A` | Shell beginning-of-line, with tmux backup-prefix compatibility |

## Platform Overview

| Host | Platform | Main desktop behavior |
|------|----------|-----------------------|
| `maverick` | NixOS | Hyprland + keyd + Ghostty + tmux + Emacs |
| `iceman` | macOS | Aerospace + Karabiner + Ghostty + tmux + Emacs |

Shared expectations:
- terminal work starts in Ghostty and usually lives in tmux
- Emacs is the primary editor
- window management uses `Hyper`
- text editing uses logical `Ctrl` via `CapsLock`
- macOS GUI shortcuts stay native on `Cmd`
- Linux app parity now covers Bitwarden, Spotify, Audacity, and `gemini-cli` through nixpkgs; the exact Claude and ChatGPT desktop apps remain macOS-only

## First-Day Workflow

### 1. Open a terminal

On either host after setup:
- press `Ctrl+Return` to open Ghostty

On a fresh `iceman` setup:
- run `just darwin-switch` first to install Ghostty, Aerospace, Karabiner-Elements, Raycast, and the other Homebrew-managed apps
- if Karabiner or Aerospace permissions are not ready yet, open Ghostty once from Raycast or Spotlight
- grant Karabiner-Elements Accessibility and Input Monitoring permissions in System Settings > Privacy & Security

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
| separate app windows | Hyprland/Aerospace |
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

### Shared Desktop Bindings

These are the main desktop bindings on both hosts:

| Physical key | Action |
|--------------|--------|
| `Ctrl+Return` | New terminal |
| `Ctrl+D` | Launcher (`Raycast` on macOS, `wofi` on Linux) |
| `Ctrl+1` .. `Ctrl+0` | Go to workspace 1..10 |
| `Ctrl+Shift+1` .. `Ctrl+Shift+0` | Move window to workspace 1..10 |
| `Ctrl+Left` / `Right` / `Down` / `Up` | Focus window left / right / down / up |
| `Ctrl+Shift+Left` / `Right` / `Down` / `Up` | Move window left / right / down / up |
| `Ctrl+F` | Fullscreen |
| `Ctrl+Space` | Toggle floating |
| `Ctrl+W` | Close window |

### macOS (iceman)

Aerospace owns desktop movement and workspace placement on `iceman`.

| Shortcut / command | Action |
|--------------------|--------|
| `Ctrl+\`` | Toggle scratch workspace `S`, creating a Ghostty there on first use |
| `Ctrl+,` / `Ctrl+.` | Previous / next workspace |
| `Ctrl+E` | Open Finder |
| `Ctrl+L` | Lock screen |
| `Alt+Tab` | AltTab app switching |
| `Cmd+Tab` | Native macOS app switching still available |
| `drs` | Rebuild nix-darwin config |
| `drt` | Check nix-darwin config without switching |

Notes:
- Mission Control desktop shortcuts and Stage Manager are disabled so Aerospace owns workspaces cleanly.
- Workspace assignments follow the shared map: `1` admin, `2` browser, `3` AI/chat, `4` editor, `5` terminal, `6` media.
- Workspaces `1` through `10` plus scratch workspace `S` are kept persistent so cycling stays stable.
- Karabiner's non-privileged agents and Aerospace start at login once installed.

### Hyprland (maverick)

Hyprland owns desktop-specific extras on `maverick`.

| Physical key | Action |
|--------------|--------|
| `Ctrl+\`` | Toggle dropdown terminal |
| `Ctrl+,` / `Ctrl+.` | Previous / next workspace |
| `Ctrl+E` | Open Thunar |
| `Ctrl+L` | Lock |
| `Ctrl+Escape` | Logout / power menu |
| `Alt+Tab` / `Alt+Shift+Tab` | Cycle windows |
| `Ctrl+Shift+S` | Area screenshot |
| `Ctrl+Shift+Print` | Full screenshot |
| `Ctrl+Alt+S` | Area screenshot and annotate in Swappy |
| `Ctrl+Alt+O` | OCR selected screen region to clipboard |
| `Ctrl+V` | Clipboard history picker |
| `Ctrl+Shift+C` | Pick a screen color to the clipboard |

### Ghostty

Ghostty is the terminal app. Use tabs lightly.

| Physical key | Action |
|--------------|--------|
| `CapsLock+Shift+T` | New tab |
| `CapsLock+,` / `CapsLock+.` | Previous / next tab |
| `CapsLock+Shift+W` | Close current tab or surface |
| `CapsLock+Shift+C` / `CapsLock+Shift+V` | Copy / paste |
| `CapsLock+Shift+Up` / `CapsLock+Shift+Down` | Jump between prompts |

Use Ghostty tabs for distinct top-level contexts:
- local work
- remote shell
- production console

If you are splitting a task into panes or want persistence, switch to tmux.

### tmux

tmux owns persistent terminal layouts.

| Physical key | Action |
|--------------|--------|
| `CapsLock+]` | Primary prefix |
| `CapsLock+A` | Backup prefix |
| `Prefix + c` | New window |
| `Prefix + |` | Split vertically into left/right panes |
| `Prefix + -` | Split horizontally into top/bottom panes |
| `Shift+Left` / `Shift+Right` | Previous / next tmux window |
| `Shift+Down` | New tmux window |
| `Prefix + Left` / `Right` / `Up` / `Down` | Move between panes |
| `Prefix + ,` / `Prefix + .` | Swap with previous / next pane |
| `Prefix + Shift+Left` / `Right` / `Up` / `Down` | Resize pane |
| `Prefix + f` | Fuzzy-find sessions/windows/panes |
| `Prefix + Space` | Copy visible URLs, paths, hashes, IPs |

Physical reminder: `Prefix` means `CapsLock+]` by default, with `CapsLock+A` still available as a backup prefix.

tmux notes:
- mouse mode is enabled, so you can select with the mouse and copy through the clipboard integration
- pane logging auto-starts for new panes

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

As elsewhere in this repo, `C-...` means the logical `Ctrl` key, which is the physical `CapsLock` key.

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

On `maverick`, use the Hyprland dropdown terminal with `Ctrl+\`` for:
- one-off git status
- package/version checks
- a quick `journalctl`, `kubectl`, or `rg`

On `iceman`, use `Ctrl+\`` to toggle into and back out of workspace `S`. On first use it creates a Ghostty there automatically, then reuses that scratch terminal afterward.

### Pattern: remote into `iceman` from Linux

1. Make sure Tailscale is connected on both machines (`ujust tailscale-status` is enough to verify).
2. Find the Mac's Tailscale IP from the menu bar app or `tailscale ip -4`.
3. On `maverick`, either launch Remmina from the app launcher or run `iceman-remote <tailscale-ip>`.
4. Sign in to the Mac as `bclark`.

`iceman-remote` defaults to `iceman`, so if Tailscale MagicDNS is enabled you can usually just run `iceman-remote`.

This setup uses macOS Screen Sharing rather than a third-party remote desktop stack. If you need a legacy VNC password for a client that cannot do user-based auth, wire it through secrets instead of hardcoding it in Nix.

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
- `ujust nixcfg-update-switch`
- `ujust nixcfg-switch`
- `ujust nixcfg-home-switch`
- `ujust rebuild`
- `ujust rollback`

`ujust nixcfg-update-switch` updates flake inputs, commits `flake.lock`, and then runs the normal host-appropriate `switch`. It refuses to run if `$HOME/nixcfg` already has uncommitted changes so it does not bundle unrelated work into the update commit.

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

1. Press `Ctrl+Alt+O` to OCR a selected screen region
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
