# Keyboard Layout Strategy

## Overview

This setup targets a consistent shortcut experience across NixOS (Hyprland) and macOS. Application shortcuts live on `Ctrl`, while window manager shortcuts live on the `Super`/Windows key. macOS remaps `Cmd` to `Ctrl` for application shortcuts so muscle memory matches Linux and Windows.

## Keyboard Layout

| Context | Shortcut Examples | Notes |
| --- | --- | --- |
| Applications | `Ctrl+C`, `Ctrl+V`, `Ctrl+T`, `Ctrl+W`, `Ctrl+S` | Same on Linux and macOS, including Emacs |
| Window manager | `Super+Return`, `Super+Q`, `Super+D`, `Super+1-9` | Matches `home/features/desktop/hyprland.nix` |
| macOS remap | `Cmd` → `Ctrl` | Implemented via Karabiner-Elements |

## Why This Design

- Separates window management from application shortcuts to avoid conflicts.
- Mirrors default Linux/Windows behavior, easing the transition between platforms.
- Keeps the Super key dedicated to tiling/window tasks across machines.

## Cross-Platform Keybinding Chain

| Action | NixOS (physical key) | macOS (physical key) | Result |
|--------|---------------------|---------------------|--------|
| Tmux prefix | Ctrl+A | Cmd+A (→Karabiner→Ctrl+A) | Tmux activates |
| Copy in terminal | Ctrl+Shift+C | Cmd+Shift+C (→Ctrl+Shift+C) | Clipboard copy |
| VS Code cmd palette | Ctrl+Shift+P | Cmd+Shift+P (→Ctrl+Shift+P) | Command palette |
| Line start (zsh) | Ctrl+A | Cmd+A (→Ctrl+A) | Cursor to start |
| Kill line (zsh) | Ctrl+K | Cmd+K (→Ctrl+K) | Kill to EOL |
| Quit app (macOS) | N/A | Cmd+Q (→Ctrl+Q) | Does NOT quit (see edge cases) |

## Tmux Keybindings

- **Prefix**: `Ctrl+A` (screen-style)
- **Split panes**: `prefix + |` (horizontal), `prefix + -` (vertical)
- **Pane navigation**: `Alt+arrows`
- **Window navigation**: `Shift+arrows`
- **Pane resize**: `Ctrl+Shift+arrows`
- **Copy mode**: `vi` keybindings (shell stays emacs via `bindkey -e`)
- **Logging**: `prefix + P` (start/stop), `prefix + Alt+P` (save history)

Note: `Ctrl+A` in tmux conflicts with shell beginning-of-line. Use `Ctrl+A Ctrl+A` to send a literal `Ctrl+A` to the shell, or use `Home` key.

## VS Code Keybindings

VS Code uses Emacs MCX extension for Emacs-compatible keybindings:
- `Ctrl+A/E`: beginning/end of line
- `Ctrl+K`: kill to end of line
- `Ctrl+N/P`: next/previous line
- `Ctrl+F/B`: forward/backward character
- `Ctrl+\``: toggle terminal
- `Ctrl+Shift+P`: command palette
- `Ctrl+Shift+F`: find in files

All keybindings use Ctrl-based keys, which works identically on both platforms via Karabiner Cmd→Ctrl remap.

## Hyprland Configuration

`home/features/desktop/hyprland.nix` sets `$mainMod = "SUPER"` and defines launcher, workspace, and window control shortcuts. No changes are required for this layout; the Super key handles all window manager actions.

Emacs-style window navigation:
- `Ctrl+Alt+B/F/P/N`: focus left/right/up/down
- `Ctrl+Alt+Shift+B/F/P/N`: move window left/right/up/down

## Karabiner Configuration

- `darwin/common/karabiner.nix` starts the Karabiner-Elements service on macOS.
- `home/features/desktop/karabiner.nix` writes `karabiner.json`, remapping left and right `Cmd` keys to their `Ctrl` counterparts.
- Some macOS system shortcuts (Spotlight, app switcher, etc.) may need manual reassignment under System Settings → Keyboard → Keyboard Shortcuts.

## Edge Cases

### Cmd+Q on macOS
With Karabiner remapping Cmd→Ctrl, pressing Cmd+Q sends Ctrl+Q instead of the macOS "Quit" command. This means:
- Apps won't quit via Cmd+Q (which is often desirable to prevent accidental quits)
- **Workaround**: Use `Alt+F4` (configured in Hyprland) or the app's menu to quit
- For macOS-native apps, reassign quit shortcuts in System Settings if needed

### Tmux prefix vs shell Ctrl+A
- Tmux captures `Ctrl+A` as its prefix key
- To send `Ctrl+A` to the shell (beginning-of-line): press `Ctrl+A Ctrl+A`
- Alternative: use `Home` key for beginning-of-line

## Emacs Integration

`home/features/editors/emacs.nix` enables vanilla Emacs (`pkgs.emacs29`), sets `EDITOR=emacs`, and adds minimal defaults. Emacs keeps its expected `Ctrl`-based bindings, matching the wider shortcut strategy.

## Customization

- Change the Hyprland modifier only if you fully understand the resulting collisions.
- Extend `karabiner.json` to add app- or device-specific exceptions; Karabiner's documentation covers per-application conditions.
- Update macOS system shortcuts to use `Ctrl` variants when desired.
- Layer personal Emacs configuration via your `~/.emacs.d` or elisp modules.

## Troubleshooting

- Karabiner requires Accessibility and Input Monitoring permissions (System Settings → Privacy & Security).
- If Karabiner mappings fail, confirm `features.desktop.karabiner.enable = true` on macOS hosts.
- Hyprland shortcuts require a running Wayland session; verify the compositor is active.
- Emacs shortcuts within terminal emulators depend on the terminal's key translation settings.

## References

- [Hyprland keybindings](https://wiki.hyprland.org/Configuring/Keybinds/)
- [Karabiner-Elements documentation](https://karabiner-elements.pqrs.org/docs/)
- [Emacs manual](https://www.gnu.org/software/emacs/manual/)
- [nix-darwin Karabiner module](https://github.com/LnL7/nix-darwin/blob/master/modules/services/karabiner-elements.nix)
