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
| Left Ctrl | Hyper (Ctrl+Alt+Cmd — no Shift) | Window management |
| Right Ctrl | Hyper (Ctrl+Alt+Cmd — no Shift) | Window management |
| Cmd | Cmd (unchanged) | macOS app shortcuts (copy/paste/save) |

**Implementation:** CapsLock→Ctrl uses `simple_modifications`. Ctrl→Hyper uses `complex_modifications` (to avoid chaining with the CapsLock rule — `simple_modifications` operates on hardware key codes and should not chain, but `complex_modifications` is the safer, more explicit approach).

**Hyper excludes Shift** so that Hyper+Shift combos (e.g., move window to workspace) are distinguishable from plain Hyper combos.

### Linux (keyd remapping daemon)

| Physical Key | Sends | Purpose |
|---|---|---|
| Caps Lock | Ctrl | Emacs keybindings, app shortcuts |
| Left Ctrl | Hyper (Mod3) | Window management |
| Right Ctrl | Hyper (Mod3) | Window management |
| Super | `layer(super_cua)` | Translates Super+key → Ctrl+key for CUA shortcuts (copy/paste/undo) |

**Implementation:** Standard xkb has no option for Ctrl→Hyper. Use `keyd` (a Linux key remapping daemon available in nixpkgs) configured via NixOS module. keyd runs at the evdev level (before Hyprland), so the remap is transparent to all apps.

```
[ids]
*

[main]
capslock = leftcontrol
leftcontrol = hyper
rightcontrol = hyper
leftmeta = layer(super_cua)
rightmeta = layer(super_cua)

[super_cua]
c = C-c
v = C-v
x = C-x
z = C-z
shift+z = C-S-z
a = C-a
s = C-s
f = C-f
w = C-w
t = C-t
n = C-n
q = C-q
l = C-l
r = C-r
p = C-p
```

Hyprland sees the remapped Hyper as `Mod3`. Bind syntax uses `MOD3` (not "Hyper"):

```
$mainMod = MOD3
bind = $mainMod, 1, workspace, 1
```

**New file:** `hosts/common/keyd.nix` — NixOS-level keyd service configuration.

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
- **Linux GUI copy/paste**: Super+C/V sends Ctrl+C/V via super_cua ✓ (also CapsLock+C/V)
- **Linux terminal copy/paste**: CapsLock+Shift+C/V sends Ctrl+Shift+C/V ✓ (Super+C sends SIGINT, not copy)
- **Emacs on Linux**: Super+C → keyd → C-c. CUA mode makes this context-aware (copy with region, prefix without). keyd-application-mapper doesn't support Hyprland, so per-app exclusion isn't possible yet.
- **VS Code + emacs-mcx**: No conflict — emacs-mcx only remaps C-a/e/k/n/p/f/b, not C-c/v/x/z

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

- Replace `$mainMod = "SUPER"` with `$mainMod = "MOD3"` (Hyper via keyd)
- Replace Ctrl+Alt+B/F/N/P focus bindings with MOD3+Arrow
- Replace Ctrl+Alt+Shift+B/F/N/P move bindings with MOD3+Shift+Arrow
- Update workspace app assignments to match shared layout
- Remove Super+Shift+S screenshot binding → re-bind to MOD3+S or keep as-is (screenshots are Linux-only, no conflict)
- Remove existing `kb_options = "ctrl:nocaps"` from Hyprland input config (CapsLock remap now handled by keyd)

## Layer 3: Declarative Config Management

### New Files

| File | Purpose |
|---|---|
| `home/features/desktop/aerospace.nix` | Aerospace TOML config via `xdg.configFile`, macOS-only guard (`lib.mkIf pkgs.stdenv.isDarwin`). Imported from the desktop module's `default.nix`. Aerospace auto-starts via its own login item (no launchd plist needed — the cask installer registers it). |
| `home/features/desktop/keybindings.nix` | Shared keybinding constants and workspace/app mappings consumed by both aerospace.nix and hyprland.nix |
| `hosts/common/keyd.nix` | NixOS-level keyd service for CapsLock→Ctrl + Ctrl→Hyper remapping (Linux only) |

### Modified Files

| File | Change |
|---|---|
| `home/features/desktop/karabiner.nix` | Replace Cmd→Ctrl remap with CapsLock→Ctrl + Ctrl→Hyper rules |
| `home/features/desktop/hyprland.nix` | Update all binds to use Hyper, update workspace app assignments, arrow keys for focus/move |
| `darwin/common/homebrew.nix` | Add `"aerospace"` cask |
| `docs/adr/ADR-003-keyboard-remapping-strategy.md` | Update to reflect new modifier strategy (Hyper for WM, CapsLock→Ctrl) |
| `docs/keyboard-layout-strategy.md` | Update to reflect new modifier strategy |

### Karabiner JSON Structure

Generated declaratively in `karabiner.nix`. Key rules:

CapsLock→Ctrl via `simple_modifications` (hardware-level, no chaining risk):

```json
{
  "simple_modifications": [
    { "from": { "key_code": "caps_lock" }, "to": [{ "key_code": "left_control" }] }
  ]
}
```

Ctrl→Hyper via `complex_modifications` (explicitly matches physical key, avoids chaining with CapsLock rule):

```json
{
  "complex_modifications": {
    "rules": [{
      "description": "Physical Ctrl → Hyper (Ctrl+Alt+Cmd, no Shift)",
      "manipulators": [
        {
          "type": "basic",
          "from": { "key_code": "left_control" },
          "to": [{ "key_code": "left_control", "modifiers": ["left_option", "left_command"] }]
        },
        {
          "type": "basic",
          "from": { "key_code": "right_control" },
          "to": [{ "key_code": "right_control", "modifiers": ["right_option", "right_command"] }]
        }
      ]
    }]
  }
}
```

Note: Hyper is defined as Ctrl+Alt+Cmd (**excluding Shift**) so that Hyper+Shift combos work as distinct bindings. No app uses this three-modifier combination, so there are zero conflicts. Aerospace binds to `ctrl+alt+cmd` in its TOML config.

### Shared Keybindings Module (`keybindings.nix`)

Exports an attribute set:

```nix
{
  workspaces = {
    "1" = { name = "admin";    darwin = ["Mail" "Notes" "Calendar" "Bitwarden"];  linux = ["thunderbird" "notes" "calendar" "bitwarden"]; };
    "2" = { name = "browser";  darwin = ["Google Chrome"];                        linux = ["firefox"]; };
    "3" = { name = "ai";       darwin = ["Claude" "ChatGPT"];                     linux = ["Claude" "ChatGPT"]; };
    "4" = { name = "editor";   darwin = ["Emacs" "Code" "Xcode"];                 linux = ["Emacs" "Code"]; };
    "5" = { name = "terminal"; darwin = ["Ghostty"];                               linux = ["Ghostty"]; };
    "6" = { name = "media";    darwin = ["Spotify" "Audacity" "GarageBand" "iMovie"]; linux = ["Spotify" "Audacity"]; };
  };
  # Workspaces 7-10: no app assignments
}
```

Both `aerospace.nix` and `hyprland.nix` import this module and generate their respective configs from it.

## Migration Notes

**This change reverses the existing Cmd→Ctrl Karabiner remap (ADR-003).** Key behavioral shifts:

- **macOS copy/paste** returns to native Cmd+C/V (was Ctrl+C/V via Cmd→Ctrl remap)
- **Tmux prefix** changes from physical Cmd+A (which sent Ctrl+A) to physical CapsLock+A (which sends Ctrl+A) — same keycode, different physical key
- **All emacs bindings** move from physical Ctrl (corner) to physical CapsLock (home row) — ergonomic improvement, muscle memory adjustment ~1-2 weeks
- **WM bindings** change from Super to Hyper (physical Ctrl key) on both platforms
- **ADR-003** (`docs/adr/ADR-003-keyboard-remapping-strategy.md`) and `docs/keyboard-layout-strategy.md` should be updated to reflect the new strategy

## Untouched

- Ghostty keybindings (Ctrl+Shift+C/V etc.) — no conflict with Hyper or super_cua
- Tmux keybindings (CapsLock+A prefix) — no conflict
- Zsh emacs mode — no conflict
- VS Code emacs-mcx navigation keys (C-a/e/k/n/p/f/b) — no conflict with super_cua
- Theme system — Aerospace is invisible (no bar/chrome to theme)
- darwin system.defaults — unchanged

## Changed (Emacs)

- **CUA mode enabled** — makes `C-c`/`C-x`/`C-v` context-aware (copy/cut/paste with active region, normal prefix/scroll without). Required because keyd super_cua translates Super+C → C-c on Linux.
- **`s-` bindings added** — `s-c`/`s-v`/`s-x`/`s-z`/`s-Z`/`s-a`/`s-s`/`s-f`/`s-w` for macOS where Emacs receives raw Super.
- **`C-S-z` bound to undo-redo** — Linux redo via keyd (Super+Shift+Z → C-S-z).

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
