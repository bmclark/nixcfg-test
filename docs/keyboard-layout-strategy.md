# Keyboard Layout Strategy

## Overview

Three modifier namespaces provide a consistent shortcut experience across NixOS (Hyprland) and macOS (Aerospace):

| Namespace | Modifier | Physical Key | Use |
|---|---|---|---|
| Text/App | Ctrl | CapsLock | Emacs navigation, shell, CUA shortcuts |
| Window Manager | Hyper (Ctrl+Alt+Cmd) | Physical Ctrl | WM operations (workspaces, focus, tiling) |
| Platform App | Cmd (macOS) / Ctrl (Linux) | Cmd / CapsLock | Copy/paste in GUI apps |

## Key Remapping

| Physical Key | macOS (Karabiner) | Linux (keyd) |
|---|---|---|
| CapsLock | Ctrl | Ctrl |
| Left/Right Ctrl | Hyper (Ctrl+Alt+Cmd) | Hyper (Mod3) |
| Cmd/Super | Cmd (unchanged) | Super (unchanged) |

## Window Manager Keybindings (identical, both platforms)

| Action | Binding |
|---|---|
| Switch to workspace 1-9 | Hyper+1-9 |
| Switch to workspace 10 | Hyper+0 |
| Move window to workspace 1-9 | Hyper+Shift+1-9 |
| Focus left/right/down/up | Hyper+←/→/↓/↑ |
| Move window left/right/down/up | Hyper+Shift+←/→/↓/↑ |
| Toggle fullscreen | Hyper+F |
| Toggle float | Hyper+Space |
| Close window | Hyper+W |
| Launch terminal | Hyper+Return |
| App launcher (Raycast/wofi) | Hyper+D |
| Dropdown terminal | Hyper+` |
| Cycle windows | Alt+Tab |

## Workspace Layout

| Workspace | Purpose | macOS Apps | Linux Apps |
|---|---|---|---|
| 1 | Admin | Mail, Notes, Calendar, Bitwarden | thunderbird, notes, calendar, bitwarden |
| 2 | Browser | Chrome | Firefox |
| 3 | AI/Chat | Claude, ChatGPT | Claude, ChatGPT |
| 4 | Editor | Emacs, VS Code, Xcode | Emacs, VS Code |
| 5 | Terminal | Ghostty | Ghostty |
| 6 | Media | Spotify, Audacity, GarageBand, iMovie | Spotify, Audacity |
| 7-10 | Flexible | (none) | (none) |

## Cross-Platform Keybinding Chain

| Action | NixOS (physical key) | macOS (physical key) | Result |
|---|---|---|---|
| Tmux prefix | CapsLock+A | CapsLock+A | Ctrl+A → Tmux activates |
| Copy (terminal) | CapsLock+Shift+C | Cmd+C | Clipboard copy |
| Copy (GUI app) | CapsLock+C | Cmd+C | Clipboard copy |
| VS Code cmd palette | CapsLock+Shift+P | Cmd+Shift+P | Command palette |
| Line start (zsh) | CapsLock+A | CapsLock+A | Ctrl+A → cursor to start |
| Kill line (zsh) | CapsLock+K | CapsLock+K | Ctrl+K → kill to EOL |
| Switch workspace 1 | Ctrl+1 | Ctrl+1 | Hyper+1 → workspace 1 |
| Move window to ws 2 | Ctrl+Shift+2 | Ctrl+Shift+2 | Hyper+Shift+2 → move |

## Emacs Keybindings (unchanged)

All emacs keybindings use Ctrl (via CapsLock). Same physical key on both platforms:
- `CapsLock+A/E`: beginning/end of line
- `CapsLock+K`: kill to end of line
- `CapsLock+N/P`: next/previous line
- `CapsLock+F/B`: forward/backward character
- `CapsLock+W`: kill region (cut)
- `CapsLock+Y`: yank (paste in emacs)

## Tmux Keybindings

- **Prefix**: `CapsLock+A` (sends Ctrl+A)
- **Split panes**: `prefix + |` / `prefix + -`
- **Pane navigation**: `Alt+arrows`
- **Window navigation**: `Shift+arrows`
- **Pane resize**: `CapsLock+Shift+arrows` (sends Ctrl+Shift+arrows)
- **Copy mode**: vi keybindings (shell stays emacs via `bindkey -e`)

Note: `Ctrl+A` in tmux conflicts with shell beginning-of-line. Use `CapsLock+A CapsLock+A` to send a literal Ctrl+A, or use `Home` key.

## Edge Cases

### macOS Copy/Paste
macOS GUI apps use Cmd+C/V/X (native). Linux GUI apps use CapsLock+C/V/X (sends Ctrl+C/V/X). This is the one intentional per-platform difference — each OS uses its native convention.

### CapsLock
CapsLock is remapped to Ctrl on both platforms. To type uppercase, use Shift.

### Physical Ctrl Key
The physical Ctrl key no longer sends Ctrl. It sends Hyper (Ctrl+Alt+Cmd on macOS, Mod3 on Linux). This is fully committed — there is no way to send "plain Ctrl" from the physical Ctrl key.

## Configuration Files

| File | Purpose |
|---|---|
| `home/features/desktop/keybindings.nix` | Shared workspace layout and app assignments |
| `home/features/desktop/karabiner.nix` | macOS: CapsLock→Ctrl + Ctrl→Hyper (Karabiner JSON) |
| `home/features/desktop/aerospace.nix` | macOS: Aerospace tiling WM config |
| `home/features/desktop/hyprland.nix` | Linux: Hyprland WM config (MOD3 bindings) |
| `hosts/common/keyd.nix` | Linux: keyd daemon for CapsLock→Ctrl + Ctrl→Hyper |

## References

- [Aerospace documentation](https://nikitabobko.github.io/AeroSpace/guide)
- [Hyprland keybindings](https://wiki.hyprland.org/Configuring/Keybinds/)
- [Karabiner-Elements documentation](https://karabiner-elements.pqrs.org/docs/)
- [keyd documentation](https://github.com/rvaiya/keyd)
