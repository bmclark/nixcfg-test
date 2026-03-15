# Editor Features

Editors managed via home-manager. Emacs is the primary editor and runs as a daemon so `emacsclient` starts instantly.

## Start Here

If you are new to this system:

1. Launch Emacs with `emacsclient -c`.
2. Open or switch projects with `C-c p p`.
3. Move between files with buffers and tabs, not with extra top-level Emacs frames.
4. Use the terminal panel for shell access inside the current project.

For the full walkthrough, read [GUIDE.md](GUIDE.md). This README is the short operational guide.

## What Emacs Is For

Use Emacs when you want:
- the main coding IDE
- writing and note-taking
- project search and symbol navigation
- integrated git, terminal, TODO tracking, and AI tools

Prefer Emacs over plain terminal editing when you need:
- LSP navigation and refactoring
- project-wide search and replace
- sidebars for files and symbols
- persistent project workspaces

## Launching And Session Model

Emacs runs as a background daemon:

| Command | Result |
|---------|--------|
| `emacsclient -c` | Open a GUI frame |
| `emacsclient -t` | Open in the current terminal |
| `emacsclient -c <file>` | Open a file directly |

Closing a frame does not stop the daemon. Buffers, workspaces, and state remain available.

## Movement And Navigation

### Buffers, windows, tabs, and workspaces

The navigation model matters:

| Concept | Meaning | Use it for |
|---------|---------|------------|
| Buffer | An open file or internal view | Switching between things you are editing |
| Window | A split inside the current Emacs frame | Seeing two or more buffers at once |
| Tab | A visible editor tab in the tab bar | Moving between current project files quickly |
| Workspace | A perspective with its own buffers/layout | Separating projects or major contexts |

### Core navigation

| Key | Action |
|-----|--------|
| `C-x C-f` | Open file |
| `C-x b` | Switch buffer |
| `C-x C-r` | Open recent file |
| `C-c p p` | Switch project and restore IDE layout |
| `C-c p f` | Find file in project |
| `M-s g` | Search across project |
| `C-s` | Search in current buffer |
| `M-g i` | Go to symbol in file |
| `M-.` | Go to definition |
| `M-?` | Find references |
| `M-g g` | Go to line |

### Panels and sidebars

| Key | Action |
|-----|--------|
| `C-c t` | Toggle file tree |
| `C-c T` | Focus file tree |
| `C-c i` | Toggle symbol outline |
| `C-c l S` | Open LSP symbol tree |
| `C-c l e` | Open project errors/problems |
| `C-c m` | Toggle minimap |

### Terminal and bottom panel

| Key | Action |
|-----|--------|
| `C-c v` | Toggle project terminal panel |
| `C-c V` | Maximize terminal / restore previous layout |

Use the terminal panel when you want shell access tied to the current project without leaving Emacs.

### Tabs and workspaces

| Key | Action |
|-----|--------|
| `Ctrl+PageUp` | Previous tab |
| `Ctrl+PageDown` | Next tab |
| `C-c w s` | Switch workspace |
| `C-c w l` | List workspaces |
| `C-c w k` | Kill workspace |

Practical rule:
- use tabs for files
- use windows for side-by-side editing
- use workspaces for separate projects or modes of work

## Daily Workflows

### Coding

| Key | Action |
|-----|--------|
| `C-c l r r` | Rename symbol |
| `C-c l a a` | Code action |
| `C-c l = =` | Format buffer |
| `C-c l D` | Search diagnostics |
| `C-c g` | Open Magit |
| `C-c b` | Toggle git blame |

### Writing and notes

| Key | Action |
|-----|--------|
| `C-c z` | Toggle focus mode |
| `C-c Z` | Enter writing mode |
| `C-c a` | Org agenda |
| `C-c c` | Org capture |

### AI and task support

| Key | Action |
|-----|--------|
| `C-c RET` | Send region/prompt to ECA |
| `C-c C-RET` | Open ECA chat |
| `C-c C` | Toggle Claude Code panel |
| `C-c X` | Launch Codex in the project root |
| `C-c n` / `C-c N` | Next / previous TODO |
| `M-s T` | Search TODOs across project |

## How Emacs Fits With The Rest Of The System

- Use Hyprland to move between desktop windows and workspaces.
- Use Emacs workspaces to separate projects once you are already inside Emacs.
- Use Ghostty + tmux when the task is terminal-first.
- Use the Emacs terminal panel when you need shell access closely tied to the file you are editing.

## Platform Notes

- **Emacs daemon:** runs via `systemd` on Linux (`services.emacs`) and via `launchd` on macOS (`launchd.agents.emacs`). Both use `--fg-daemon` and set `PKG_CONFIG_PATH` for jinx spell checking.
- `emacsclient -c` and `emacsclient -t` work identically on both platforms.

## Design Notes

- The custom bindings are intentionally compatible with the VS Code Emacs MCX setup.
- Emacs is treated as the primary IDE, not a secondary editor.
- `GUIDE.md` is the deep manual; this README should stay short and operational.

See [GUIDE.md](GUIDE.md) for the full user guide, [ADR-003](../../../docs/adr/ADR-003-keyboard-remapping-strategy.md) for the broader keyboard model, and [ADR-014](../../../docs/adr/ADR-014-macos-platform-parity.md) for platform parity decisions.
