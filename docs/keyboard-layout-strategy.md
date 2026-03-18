# Keyboard Layout Strategy

## Overview

The keyboard model is split into three namespaces so text editing, app shortcuts, and window management stop fighting each other:

| Namespace | Logical Modifier | Physical Key | Primary Use |
|---|---|---|---|
| Text / editing | `Ctrl` | `CapsLock` | Emacs navigation, shell editing, terminal shortcuts, Linux app shortcuts |
| Window manager | `Hyper` | Physical `Ctrl` | Hyprland / Aerospace workspaces, focus, movement, layout |
| Platform CUA | `Cmd` on macOS, `Super` on Linux | `Cmd` / `Super` | Copy/paste/undo/redo — same physical key on both platforms via keyd super_cua layer |

## Physical Remapping

| Physical Key | macOS (Karabiner) | Linux (keyd) |
|---|---|---|
| `CapsLock` | `Ctrl` | `Ctrl` |
| `Left/Right Ctrl` | `Hyper` (`Ctrl+Alt+Cmd`) | `Hyper` (`Mod3`) |
| `Cmd` / `Super` | unchanged | `layer(super_cua)` — translates `Super+key` to `Ctrl+key` for CUA shortcuts |

How to read the rest of the docs:

- `Ctrl+X` means the logical `Ctrl` modifier, which is the physical `CapsLock` key on both hosts.
- `Hyper+X` means the physical `Ctrl` key on both hosts.
- User-facing shortcut tables should prefer the physical key sequence where possible.

## Shared Window-Manager Bindings

These bindings exist on both hosts:

| Physical key | Logical binding | Action |
|---|---|---|
| `Ctrl+Return` | `Hyper+Return` | Launch terminal |
| `Ctrl+D` | `Hyper+D` | App launcher |
| `Ctrl+1-9` | `Hyper+1-9` | Switch to workspace 1-9 |
| `Ctrl+0` | `Hyper+0` | Switch to workspace 10 |
| `Ctrl+Shift+1-9` | `Hyper+Shift+1-9` | Move window to workspace 1-9 |
| `Ctrl+Shift+0` | `Hyper+Shift+0` | Move window to workspace 10 |
| `Ctrl+Left` / `Right` / `Down` / `Up` | `Hyper+Left` / `Right` / `Down` / `Up` | Focus left / right / down / up |
| `Ctrl+Shift+Left` / `Right` / `Down` / `Up` | `Hyper+Shift+Left` / `Right` / `Down` / `Up` | Move window left / right / down / up |
| `Ctrl+F` | `Hyper+F` | Toggle fullscreen |
| `Ctrl+Space` | `Hyper+Space` | Toggle floating |
| `Ctrl+W` | `Hyper+W` | Close window |

## Platform-Specific Desktop Bindings

| Action | macOS physical key | Linux physical key |
|---|---|---|
| Scratch access | `Ctrl+\`` toggles workspace `S`, creating a Ghostty there on first use | `CapsLock+\`` toggles guake-style dropdown terminal (top third) |
| App switcher | `Alt+Tab` (AltTab), `Cmd+Tab` still native | `Alt+Tab` (hyprshell visual switcher) |
| Previous / next workspace | `Ctrl+,` / `Ctrl+.` | `Ctrl+,` / `Ctrl+.` |
| File manager | `Ctrl+E` opens Finder | `Ctrl+E` opens Thunar |
| Lock screen | `Ctrl+L` | `Ctrl+L` |
| Session menu | use macOS UI | `Ctrl+Escape` |
| Region screenshot | use macOS Screenshot | `Ctrl+Shift+S` |
| Screenshot + annotate | use macOS Screenshot / Preview | `Ctrl+Alt+S` |
| OCR selected region | use macOS Live Text | `Ctrl+Alt+O` |
| Clipboard history | use Raycast / app-native flows | `Ctrl+V` |

## Shared Workspace Layout

Workspace assignments come from `home/features/desktop/keybindings.nix`:

| Workspace | Purpose | macOS Apps | Linux Apps |
|---|---|---|---|
| `1` | Admin | Mail, Notes, Calendar, Bitwarden | thunderbird, notes, calendar, Bitwarden |
| `2` | Browser | Safari, Google Chrome | firefox, chromium |
| `3` | AI / chat | Claude, ChatGPT, Codex | Claude, ChatGPT |
| `4` | Editor | Emacs, Code, Xcode | Emacs, Code |
| `5` | Terminal | Ghostty | Ghostty |
| `6` | Media | Spotify, Audacity, GarageBand, iMovie | Spotify, Audacity |
| `7-10` | Flexible | no automatic assignment | no automatic assignment |
| `S` | Scratch | Ghostty scratch workspace on macOS | n/a |

## Cross-Platform CUA Shortcuts (Cmd+C/V/X/Z)

On macOS, `Cmd+C/V/X/Z` is native. On Linux, keyd's `super_cua` layer translates `Super+C` → `Ctrl+C`, etc. — so the **same physical key** (`Cmd`/`Super`) does copy/paste/undo on both platforms.

| Action | macOS physical key | Linux physical key | Result |
|---|---|---|---|
| Copy | `Cmd+C` | `Super+C` | clipboard copy (`Ctrl+C` via keyd) |
| Paste | `Cmd+V` | `Super+V` | clipboard paste (`Ctrl+V` via keyd) |
| Cut | `Cmd+X` | `Super+X` | clipboard cut (`Ctrl+X` via keyd) |
| Undo | `Cmd+Z` | `Super+Z` | undo (`Ctrl+Z` via keyd) |
| Redo | `Cmd+Shift+Z` | `Super+Shift+Z` | redo (`Ctrl+Shift+Z` via keyd) |
| Select all | `Cmd+A` | `Super+A` | select all (`Ctrl+A` via keyd) |
| Save | `Cmd+S` | `Super+S` | save (`Ctrl+S` via keyd) |
| Find | `Cmd+F` | `Super+F` | find (`Ctrl+F` via keyd) |

### Emacs special handling

keyd operates at evdev level and **cannot exclude per-app** (keyd-application-mapper doesn't support Hyprland). On Linux, `Super+C` reaches Emacs as `Ctrl+C` — which is an Emacs prefix key. CUA mode handles this:

- **CUA mode** (enabled in init.el): `C-c` with active region → copy, without region → normal prefix. Same for `C-x` (cut/prefix) and `C-v` (paste).
- **macOS Emacs**: receives raw `Super` as `s-` modifier. `s-c/v/x/z` bindings handle copy/paste/undo directly.

### VS Code

VS Code with emacs-mcx works without issues — emacs-mcx only remaps navigation keys (`C-a/e/k/n/p/f/b`), not `C-c/v/x/z`. keyd's `Super+C → Ctrl+C` hits VS Code's native copy.

## Common Physical-Key Examples

| Action | macOS physical key | Linux physical key | Result |
|---|---|---|---|
| Shell beginning of line | `CapsLock+A` | `CapsLock+A` | logical `Ctrl+A` |
| tmux primary prefix | `CapsLock+]` | `CapsLock+]` | logical `Ctrl+]` |
| tmux backup prefix | `CapsLock+A` | `CapsLock+A` | logical `Ctrl+A` |
| tmux swap previous / next pane | `Prefix + CapsLock+,` / `Prefix + CapsLock+.` | `Prefix + CapsLock+,` / `Prefix + CapsLock+.` | swap with previous / next pane |
| Ghostty previous / next tab | `CapsLock+,` / `CapsLock+.` | `CapsLock+,` / `CapsLock+.` | logical `Ctrl+,` / `Ctrl+.` |
| Ghostty copy | `CapsLock+Shift+C` | `CapsLock+Shift+C` | logical `Ctrl+Shift+C` |
| GUI app copy | `Cmd+C` | `Super+C` | clipboard copy (native on macOS, `Ctrl+C` via keyd on Linux) |
| VS Code command palette | `Cmd+Shift+P` | `Super+Shift+P` | open command palette |
| Launch terminal | `Ctrl+Return` | `Ctrl+Return` | logical `Hyper+Return` |
| Switch to workspace 1 | `Ctrl+1` | `Ctrl+1` | logical `Hyper+1` |
| Move window to workspace 2 | `Ctrl+Shift+2` | `Ctrl+Shift+2` | logical `Hyper+Shift+2` |

## Edge Cases

- `CapsLock` no longer toggles caps. Use `Shift` for uppercase.
- The physical `Ctrl` key no longer sends plain `Ctrl`. It is fully committed to `Hyper`.
- macOS GUI shortcuts stay native: `Cmd+C/V/X`, `Cmd+Tab`, `Cmd+Q`, and similar shortcuts are not remapped. On Linux, keyd's `super_cua` layer translates these from `Super` to `Ctrl`, so the same physical key works on both platforms.
- **Emacs on Linux**: keyd translates `Super+C` → `C-c`, which is an Emacs prefix key. CUA mode (enabled in init.el) makes this context-aware: copy when a region is active, prefix otherwise. On macOS, Emacs receives raw `s-c` and uses dedicated `s-` bindings.
- AltTab adds physical `Alt+Tab` app switching on macOS without removing native `Cmd+Tab`.
- Ghostty and tmux still use logical `Ctrl`, so their shortcuts are physically `CapsLock` combos in this setup.
- `Hyper+\`` on macOS now treats workspace `S` as a reusable Ghostty scratch terminal, but it is still not a true Hyprland-style dropdown terminal.
- AeroSpace keeps `1..10` and `S` persistent so workspace cycling and assignments remain stable.

## Configuration Files

| File | Purpose |
|---|---|
| `home/features/desktop/keybindings.nix` | Shared workspace layout and app assignments |
| `home/features/desktop/karabiner.nix` | macOS remapping rules: `CapsLock -> Ctrl`, physical `Ctrl -> Hyper` |
| `darwin/common/karabiner.nix` | Starts Karabiner's non-privileged agents at login |
| `home/features/desktop/aerospace.nix` | macOS Aerospace config and bindings |
| `home/features/desktop/hyprland.nix` | Linux Hyprland bindings and window rules |
| `hosts/common/keyd.nix` | Linux key remapping daemon |

## References

- [Aerospace documentation](https://nikitabobko.github.io/AeroSpace/guide)
- [Hyprland keybindings](https://wiki.hyprland.org/Configuring/Keybinds/)
- [Karabiner-Elements documentation](https://karabiner-elements.pqrs.org/docs/)
- [keyd documentation](https://github.com/rvaiya/keyd)
