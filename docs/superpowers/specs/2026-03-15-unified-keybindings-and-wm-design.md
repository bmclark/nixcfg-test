# Unified Keybindings & Window Management

**Date:** 2026-03-15
**Status:** Approved

## Goal

Unify keybindings across macOS and Linux with three cleanly separated modifier namespaces: Ctrl (emacs/app), Hyper (window management), and Cmd/Super (platform-native app shortcuts). Add Aerospace as a macOS tiling WM to match Hyprland's behavior and keybindings.

## Design Principles

1. **Emacs everywhere** — Ctrl is the primary app/text modifier (emacs keybindings in shell, editors, and Cocoa text fields)
2. **Hyper for WM** — a dedicated modifier that no app uses, eliminating all conflicts
3. **Platform-native app shortcuts** — Cmd+C/V/X on macOS, Ctrl+C/V/X on Linux; don't fight the OS
4. **Single source of truth** — workspace layout and app assignments defined once, consumed by both WMs
5. **Caps Lock → Ctrl** — better ergonomics for the most-used modifier

## Layer 1: Key Remapping

### macOS (Karabiner-Elements)

Declaratively managed via home-manager (`home.file.".config/karabiner/karabiner.json"`).

| Physical Key | Sends | Purpose |
|---|---|---|
| Caps Lock | Ctrl | Emacs keybindings, app shortcuts |
| Left Ctrl | Hyper (Ctrl+Alt+Shift+Cmd) | Window management |
| Right Ctrl | Hyper (Ctrl+Alt+Shift+Cmd) | Window management |
| Cmd | Cmd (unchanged) | macOS app shortcuts (copy/paste/save) |

### Linux (Hyprland input / xkb)

| Physical Key | Sends | Purpose |
|---|---|---|
| Caps Lock | Ctrl | Emacs keybindings, app shortcuts |
| Left Ctrl | Hyper (Mod3) | Window management |
| Right Ctrl | Hyper (Mod3) | Window management |
| Super | Super (unchanged) | Unused for WM; available for OS-level if needed |

### Resulting Modifier Namespaces

| Namespace | Modifier | Use |
|---|---|---|
| Text/App | Ctrl (via Caps Lock) | Emacs navigation, CUA shortcuts, terminal interrupt |
| Window Manager | Hyper (via physical Ctrl) | All WM operations |
| Platform App | Cmd (macOS) / Ctrl (Linux) | Copy/paste in GUI apps |

### Edge Cases

- **Ctrl+C interrupt** in macOS terminal: CapsLock+C sends Ctrl+C ✓
- **Caps Lock for actual caps**: lost (use Shift; standard trade-off)
- **Physical Ctrl no longer sends Ctrl**: fully committed to Hyper
- **Linux GUI copy/paste**: CapsLock+C/V sends Ctrl+C/V ✓
- **Linux terminal copy/paste**: CapsLock+Shift+C/V sends Ctrl+Shift+C/V ✓

## Layer 2: Window Management

### Workspace Layout (shared, both platforms)

| Workspace | Purpose | Auto-assigned apps |
|---|---|---|
| 1 | Admin | Mail, Notes, Calendar, Bitwarden |
| 2 | Browser | Chrome (macOS) / Firefox (Linux) |
| 3 | AI/Chat | Claude, ChatGPT |
| 4 | Editor | Emacs, VS Code, Xcode (macOS only) |
| 5 | Terminal | Ghostty |
| 6 | Media | Spotify, Audacity, GarageBand, iMovie |
| 7-10 | Flexible | No auto-assignment |

### Unified Keybindings (identical on both platforms)

| Action | Binding |
|---|---|
| Switch to workspace 1-9 | Hyper+1-9 |
| Switch to workspace 10 | Hyper+0 |
| Move window to workspace 1-9 | Hyper+Shift+1-9 |
| Move window to workspace 10 | Hyper+Shift+0 |
| Focus left / right / down / up | Hyper+← / → / ↓ / ↑ |
| Move window left / right / down / up | Hyper+Shift+← / → / ↓ / ↑ |
| Toggle fullscreen | Hyper+F |
| Toggle float | Hyper+Space |
| Close window | Hyper+W |
| Launch terminal | Hyper+Return |
| App launcher (Raycast / wofi) | Hyper+D |
| Dropdown terminal (scratchpad) | Hyper+backtick |
| Cycle windows | Alt+Tab (native on both platforms) |

### Tiling Behavior

- **Aerospace (macOS):** BSP (binary space partition) — closest equivalent to Hyprland's dwindle
- **Hyprland (Linux):** dwindle layout (already configured)
- New windows split the focused container automatically
- Dialogs and popups float by default on both platforms

### Scratchpad Terminal

- Dedicated hidden workspace, toggles visibility on Hyper+backtick
- Ghostty instance, ~50% screen height, anchored to top of screen
- Same behavior on both platforms (Aerospace scratchpad / Hyprland special workspace)

### Aerospace-Specific Config

- BSP tiling mode
- No window gaps (or match Hyprland: 5px inner, 10px outer — user preference)
- No window decorations management (macOS handles this)
- Automatic float for: system dialogs, preferences windows, Raycast
- Single monitor configuration

### Hyprland Changes

- Replace all `Super` / `$mainMod` bindings with Hyper
- Replace Ctrl+Alt+B/F/N/P focus bindings with Hyper+Arrow
- Replace Ctrl+Alt+Shift+B/F/N/P move bindings with Hyper+Shift+Arrow
- Update workspace app assignments to match shared layout
- Remove Super+Shift+S screenshot binding → re-bind to Hyper+S or keep as-is (screenshots are Linux-only, no conflict)

## Layer 3: Declarative Config Management

### New Files

| File | Purpose |
|---|---|
| `home/features/desktop/aerospace.nix` | Aerospace TOML config via `xdg.configFile`, macOS-only guard (`lib.mkIf pkgs.stdenv.isDarwin`) |
| `home/features/desktop/keybindings.nix` | Shared keybinding constants and workspace/app mappings consumed by both aerospace.nix and hyprland.nix |

### Modified Files

| File | Change |
|---|---|
| `home/features/desktop/karabiner.nix` | Replace Cmd→Ctrl remap with CapsLock→Ctrl + Ctrl→Hyper rules |
| `home/features/desktop/hyprland.nix` | Update all binds to use Hyper, update workspace app assignments, arrow keys for focus/move |
| `darwin/common/homebrew.nix` | Add `"aerospace"` cask |

### Karabiner JSON Structure

Generated declaratively in `karabiner.nix`. Key rules:

```json
{
  "simple_modifications": [
    { "from": { "key_code": "caps_lock" }, "to": [{ "key_code": "left_control" }] },
    { "from": { "key_code": "left_control" }, "to": [{ "key_code": "left_shift", "modifiers": ["left_control", "left_option", "left_command"] }] },
    { "from": { "key_code": "right_control" }, "to": [{ "key_code": "right_shift", "modifiers": ["right_control", "right_option", "right_command"] }] }
  ]
}
```

Note: Hyper is implemented as all four modifiers pressed simultaneously (Ctrl+Alt+Shift+Cmd). The physical Ctrl key sends this chord, which Aerospace intercepts. No app uses this modifier combination, so there are zero conflicts.

### Shared Keybindings Module (`keybindings.nix`)

Exports an attribute set:

```nix
{
  workspaces = {
    "1" = { name = "admin"; apps = ["Mail" "Notes" "Calendar" "Bitwarden"]; };
    "2" = { name = "browser"; apps.darwin = ["Google Chrome"]; apps.linux = ["firefox"]; };
    "3" = { name = "ai"; apps = ["Claude" "ChatGPT"]; };
    "4" = { name = "editor"; apps = ["Emacs" "Code" "Xcode"]; };
    "5" = { name = "terminal"; apps = ["Ghostty"]; };
    "6" = { name = "media"; apps = ["Spotify" "Audacity" "GarageBand" "iMovie"]; };
  };
  # Workspaces 7-10: no app assignments
}
```

Both `aerospace.nix` and `hyprland.nix` import this module and generate their respective configs from it.

## Untouched

- Ghostty keybindings (Ctrl+Shift+C/V etc.) — no conflict with Hyper
- Tmux keybindings (CapsLock+A prefix) — no conflict
- Zsh emacs mode — no conflict
- Emacs keybindings — no conflict
- VS Code emacs-mcx — no conflict
- Theme system — Aerospace is invisible (no bar/chrome to theme)
- darwin system.defaults — unchanged

## Out of Scope

- Multi-monitor configuration
- Mouse/trackpad tuning (already configured)
- Accessibility settings
- Status bar (waybar on Linux; macOS menu bar is native)
- Screenshot bindings (Linux-only, can be addressed separately)

## Validation

- `just check` must pass after all changes
- Manual testing: verify Hyper key triggers WM actions, Caps Lock triggers Ctrl, no binding conflicts
- Test on both platforms: macOS (macmini) and Linux (NixOS)
