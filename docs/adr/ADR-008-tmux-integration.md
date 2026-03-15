# ADR-008: Tmux Integration and Session Logging

**Status**: Accepted
**Date**: 2026-03-14

## Context

The configuration needs a terminal multiplexer for:
- Session management (multiple panes/windows within a single terminal)
- Session persistence (detach/reattach workflows)
- Session logging to compensate for Ghostty lacking auto-logging (GitHub #5209)
- Consistent experience across NixOS and macOS

## Decision

**Tmux via home-manager** with the following configuration:

- **Prefix**: `Ctrl+A` (screen-style, avoids conflict with Emacs `Ctrl+B`)
- **Key mode**: `vi` for copy-mode; shell stays in emacs mode via `bindkey -e` in zsh
- **Mouse**: enabled for pane selection and resizing
- **Theme**: Dracula plugin with CPU/RAM/battery status segments
- **Logging**: `tmux-logging` plugin stores session logs in `~/tmux-logs/`
- **Plugins**: sensible, dracula, yank, pain-control, logging (all from nixpkgs)
- **Keybindings**: `|`/`-` for splits, Alt+arrows for pane nav, Shift+arrows for windows

### Session Logging

Ghostty has no built-in session logging capability (see [GitHub issue #5209](https://github.com/ghostty-org/ghostty/issues/5209)). The tmux-logging plugin fills this gap:
- `prefix + P`: start/stop logging current pane
- `prefix + Alt+P`: save complete pane history
- `prefix + Alt+c`: clear pane history
- Logs saved to `~/tmux-logs/` with timestamps

## Consequences

**Positive**
- Session logging gap filled without switching terminal emulators
- Consistent across NixOS and macOS
- Declarative plugin management via home-manager (no TPM runtime manager)
- Vi copy-mode allows efficient text selection while shell retains emacs keybindings

**Negative**
- Adds a layer between terminal and shell (minor complexity)
- Users must remember tmux prefix for multiplexer commands
- Logging requires manual activation per pane

**Neutral**
- `Ctrl+A` prefix conflicts with shell beginning-of-line, but `Ctrl+A Ctrl+A` sends literal `Ctrl+A`
- May eventually be replaced by Ghostty native logging if implemented upstream
