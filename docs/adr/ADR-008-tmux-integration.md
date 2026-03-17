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

- **Prefix**: `Ctrl+]` primary with `Ctrl+A` retained as a backup during transition
- **Key mode**: `emacs` for copy-mode; shell stays in emacs mode via `bindkey -e` in zsh
- **Mouse**: enabled for pane selection, resizing, and clipboard-backed selection
- **Theme**: Dracula plugin with CPU/RAM/battery status segments
- **Logging**: `tmux-logging` plugin stores session logs in `~/tmux-logs/`
- **Plugins**: sensible, dracula, yank, pain-control, logging, resurrect, continuum, tmux-fzf, thumbs (all from nixpkgs)
- **Keybindings**: `|`/`-` for splits, Shift+Left/Right for tmux windows, Shift+Down for new window, Prefix+arrows for pane nav, Prefix+`,`/`.` for pane swap, Prefix+Shift+arrows for resize

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
- Copy mode now matches shell-style emacs movement, reducing context switching
- Mouse selection can copy directly into the clipboard flow

**Negative**
- Adds a layer between terminal and shell (minor complexity)
- Users must remember tmux prefix for multiplexer commands
- The backup `Ctrl+A` prefix still steals shell beginning-of-line inside tmux until it is removed

**Neutral**
- Logging auto-starts for new panes, but the manual logging commands still exist
- May eventually be replaced by Ghostty native logging if implemented upstream
