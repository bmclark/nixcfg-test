# Unified Keybindings & Window Management Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Unify keybindings across macOS and Linux with Hyper (CapsLock→Ctrl, Ctrl→Hyper) and add Aerospace as macOS tiling WM matching Hyprland.

**Architecture:** Three layers — key remapping (Karabiner/keyd), window management (Aerospace/Hyprland), and shared config (keybindings.nix). Both WMs consume a shared workspace/app-assignment module. Hyper is defined as Ctrl+Alt+Cmd (no Shift) so Hyper+Shift combos work.

**Tech Stack:** nix-darwin, NixOS, home-manager, Karabiner-Elements, Aerospace, keyd, Hyprland

**Spec:** `docs/superpowers/specs/2026-03-15-unified-keybindings-and-wm-design.md`

---

## Chunk 1: Shared Keybindings Module + Karabiner

### Task 1: Create shared keybindings module

**Files:**
- Create: `home/features/desktop/keybindings.nix`

- [ ] **Step 1: Create keybindings.nix**

This module exports workspace layout and app assignments consumed by both Aerospace and Hyprland:

```nix
# Shared workspace layout and app assignments for cross-platform window management.
# Consumed by aerospace.nix (macOS) and hyprland.nix (Linux).
{
  workspaces = {
    "1" = { name = "admin";    darwin = ["Mail" "Notes" "Calendar" "Bitwarden"];                    linux = ["thunderbird" "notes" "calendar" "bitwarden"]; };
    "2" = { name = "browser";  darwin = ["Google Chrome"];                                          linux = ["firefox"]; };
    "3" = { name = "ai";       darwin = ["Claude" "ChatGPT"];                                       linux = ["Claude" "ChatGPT"]; };
    "4" = { name = "editor";   darwin = ["Emacs" "Code" "Xcode"];                                   linux = ["Emacs" "Code"]; };
    "5" = { name = "terminal"; darwin = ["Ghostty"];                                                 linux = ["Ghostty"]; };
    "6" = { name = "media";    darwin = ["Spotify" "Audacity" "GarageBand" "iMovie"];                linux = ["Spotify" "Audacity"]; };
  };
  # Workspaces 7-10: no app assignments (flexible use)
}
```

- [ ] **Step 2: Commit**

```bash
git add home/features/desktop/keybindings.nix
git commit -m "feat: add shared keybindings module for cross-platform workspace config"
```

### Task 2: Update Karabiner config (CapsLock→Ctrl, Ctrl→Hyper)

**Files:**
- Modify: `home/features/desktop/karabiner.nix` (full rewrite of lines 9-54)

- [ ] **Step 1: Replace karabiner.nix content**

Replace the entire `karabinerConfig` definition and its rules. The new config:
- CapsLock→Ctrl via `simple_modifications` (hardware-level)
- Ctrl→Hyper via `complex_modifications` with `modifiers.optional = ["any"]` so combos pass through
- Hyper = Ctrl+Alt+Cmd (no Shift, so Hyper+Shift works)

Replace lines 9-54 (from `karabinerConfig = {` through the closing of `profiles`) with:

```nix
  karabinerConfig = {
    global = {
      ask_for_confirmation_before_quit = true;
      show_in_menu_bar = true;
    };
    profiles = [
      {
        name = "Default";
        selected = true;
        # CapsLock → Ctrl at hardware level (no chaining risk)
        simple_modifications = [
          {
            from.key_code = "caps_lock";
            to = [{key_code = "left_control";}];
          }
        ];
        complex_modifications = {
          rules = [
            {
              description = "Physical Left Ctrl → Hyper (Ctrl+Alt+Cmd, no Shift)";
              manipulators = [
                {
                  type = "basic";
                  from = {
                    key_code = "left_control";
                    modifiers.optional = ["any"];
                  };
                  to = [
                    {
                      key_code = "left_control";
                      modifiers = ["left_option" "left_command"];
                    }
                  ];
                }
              ];
            }
            {
              description = "Physical Right Ctrl → Hyper (Ctrl+Alt+Cmd, no Shift)";
              manipulators = [
                {
                  type = "basic";
                  from = {
                    key_code = "right_control";
                    modifiers.optional = ["any"];
                  };
                  to = [
                    {
                      key_code = "right_control";
                      modifiers = ["right_option" "right_command"];
                    }
                  ];
                }
              ];
            }
          ];
        };
      }
    ];
  };
```

- [ ] **Step 2: Update the config comment**

After the edit above, find the comment `# Keep application shortcuts on Ctrl while WM shortcuts live on Super.` and replace with:

```nix
      # CapsLock → Ctrl (emacs), physical Ctrl → Hyper (WM via Aerospace).
```

- [ ] **Step 3: Run `just check`**

Run: `just check`
Expected: No errors. The Karabiner JSON structure is valid Nix.

- [ ] **Step 4: Commit**

```bash
git add home/features/desktop/karabiner.nix
git commit -m "feat: remap CapsLock→Ctrl, Ctrl→Hyper for unified WM keybindings"
```

### Task 3: Add Aerospace cask to Homebrew

**Files:**
- Modify: `darwin/common/homebrew.nix:18-30` (casks list)

- [ ] **Step 1: Add aerospace tap and cask**

Add to `darwin/common/homebrew.nix`. First, add a `taps` list after `onActivation.cleanup` (line 8):

```nix
    taps = [
      "nikitabobko/tap" # Aerospace tiling WM
    ];
```

Then add `"nikitabobko/tap/aerospace"` to the casks list in alphabetical order (first entry, before `"audacity"`):

```nix
      "nikitabobko/tap/aerospace" # Tiling window manager (i3/Hyprland-like)
```

- [ ] **Step 2: Run `just check`**

Run: `just check`
Expected: No errors.

- [ ] **Step 3: Commit**

```bash
git add darwin/common/homebrew.nix
git commit -m "feat: add aerospace tiling WM cask"
```

---

## Chunk 2: Aerospace Configuration (macOS WM)

### Task 4: Create Aerospace config module

**Files:**
- Create: `home/features/desktop/aerospace.nix`

- [ ] **Step 1: Create aerospace.nix**

This module generates Aerospace TOML config from the shared keybindings module. Aerospace binds use `ctrl-alt-cmd` (Hyper without Shift) and `ctrl-alt-cmd-shift` (Hyper+Shift):

```nix
# Aerospace tiling window manager for macOS.
# Keybindings mirror Hyprland (Linux) using Hyper (Ctrl+Alt+Cmd via Karabiner).
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.desktop.aerospace;
  kb = import ./keybindings.nix;

  # Build workspace-to-app TOML blocks for macOS (matches by app display name)
  appAssignments = concatStringsSep "\n" (
    mapAttrsToList (ws: def:
      concatStringsSep "\n" (
        map (app: "[[on-window-detected]]\nif.app-name-regex-substring = '${app}'\nrun = 'move-node-to-workspace ${ws}'")
        def.darwin
      )
    ) kb.workspaces
  );
in {
  options.features.desktop.aerospace.enable =
    mkEnableOption "Aerospace tiling window manager configuration";

  config =
    mkIf cfg.enable
    (mkIf pkgs.stdenv.isDarwin {
      xdg.configFile."aerospace/aerospace.toml".text = ''
        # Aerospace configuration — generated by home-manager
        # Mirrors Hyprland keybindings via shared keybindings.nix

        after-login-command = []
        after-startup-command = []

        # BSP tiling (closest to Hyprland dwindle)
        default-root-container-layout = 'tiles'
        default-root-container-orientation = 'auto'

        # Match Hyprland gaps
        [gaps]
        inner.horizontal = 5
        inner.vertical = 5
        outer.left = 10
        outer.right = 10
        outer.top = 10
        outer.bottom = 10

        # --- Keybindings ---------------------------------------------------------
        # Hyper = ctrl-alt-cmd (physical Ctrl key via Karabiner)

        [mode.main.binding]
        # Workspace switching
        ctrl-alt-cmd-1 = 'workspace 1'
        ctrl-alt-cmd-2 = 'workspace 2'
        ctrl-alt-cmd-3 = 'workspace 3'
        ctrl-alt-cmd-4 = 'workspace 4'
        ctrl-alt-cmd-5 = 'workspace 5'
        ctrl-alt-cmd-6 = 'workspace 6'
        ctrl-alt-cmd-7 = 'workspace 7'
        ctrl-alt-cmd-8 = 'workspace 8'
        ctrl-alt-cmd-9 = 'workspace 9'
        ctrl-alt-cmd-0 = 'workspace 10'

        # Move window to workspace
        ctrl-alt-cmd-shift-1 = 'move-node-to-workspace 1'
        ctrl-alt-cmd-shift-2 = 'move-node-to-workspace 2'
        ctrl-alt-cmd-shift-3 = 'move-node-to-workspace 3'
        ctrl-alt-cmd-shift-4 = 'move-node-to-workspace 4'
        ctrl-alt-cmd-shift-5 = 'move-node-to-workspace 5'
        ctrl-alt-cmd-shift-6 = 'move-node-to-workspace 6'
        ctrl-alt-cmd-shift-7 = 'move-node-to-workspace 7'
        ctrl-alt-cmd-shift-8 = 'move-node-to-workspace 8'
        ctrl-alt-cmd-shift-9 = 'move-node-to-workspace 9'
        ctrl-alt-cmd-shift-0 = 'move-node-to-workspace 10'

        # Window focus (arrow keys)
        ctrl-alt-cmd-left = 'focus left'
        ctrl-alt-cmd-right = 'focus right'
        ctrl-alt-cmd-down = 'focus down'
        ctrl-alt-cmd-up = 'focus up'

        # Window movement (arrow keys + shift)
        ctrl-alt-cmd-shift-left = 'move left'
        ctrl-alt-cmd-shift-right = 'move right'
        ctrl-alt-cmd-shift-down = 'move down'
        ctrl-alt-cmd-shift-up = 'move up'

        # Window state
        ctrl-alt-cmd-f = 'fullscreen'
        ctrl-alt-cmd-space = 'layout floating tiling'
        ctrl-alt-cmd-w = 'close'

        # Launch terminal
        ctrl-alt-cmd-enter = 'exec-and-forget open -a Ghostty'

        # App launcher (Raycast)
        ctrl-alt-cmd-d = 'exec-and-forget open -a Raycast'

        # Dropdown terminal (scratchpad workspace toggle)
        # Aerospace doesn't have Hyprland's "special workspace" concept.
        # Use a named workspace 'S' and toggle between it and the previous workspace.
        ctrl-alt-cmd-backtick = 'workspace S'

        # --- App Assignments -----------------------------------------------------
        ${appAssignments}
      '';
    });
}
```

- [ ] **Step 2: Import aerospace.nix in desktop default.nix**

Add `./aerospace.nix` to the imports list in `home/features/desktop/default.nix` (after `./karabiner.nix` on line 9):

```nix
    ./aerospace.nix
```

- [ ] **Step 3: Run `just check`**

Run: `just check`
Expected: No errors. The module is guarded by `isDarwin` and `cfg.enable`.

- [ ] **Step 4: Commit**

```bash
git add home/features/desktop/aerospace.nix home/features/desktop/default.nix
git commit -m "feat: add Aerospace tiling WM config for macOS with shared keybindings"
```

### Task 5: Enable Aerospace in macOS host config

**Files:**
- Modify: `home/bclark/macmini.nix:33` (near `karabiner.enable = true`)

- [ ] **Step 1: Add Aerospace enable flag**

In `home/bclark/macmini.nix`, add after the existing `karabiner.enable = true;` (line 33):

```nix
      aerospace.enable = true;
```

- [ ] **Step 2: Run `just check`**

Run: `just check`
Expected: No errors.

- [ ] **Step 3: Commit**

```bash
git add home/bclark/macmini.nix
git commit -m "feat: enable Aerospace on macOS host"
```

---

## Chunk 3: Hyprland Migration + keyd

### Task 6: Create keyd config for Linux key remapping

**Files:**
- Create: `hosts/common/keyd.nix`

- [ ] **Step 1: Create keyd.nix**

NixOS-level keyd service for CapsLock→Ctrl and Ctrl→Hyper remapping:

```nix
# keyd: system-level key remapping daemon.
# Remaps CapsLock→Ctrl (emacs) and physical Ctrl→Hyper (WM).
# Runs at evdev level, transparent to Hyprland and all apps.
{...}: {
  services.keyd = {
    enable = true;
    keyboards.default = {
      ids = ["*"];
      settings = {
        main = {
          capslock = "leftcontrol";
          leftcontrol = "hyper";
          rightcontrol = "hyper";
        };
      };
    };
  };
}
```

- [ ] **Step 2: Import keyd.nix in hosts/common/default.nix**

`hosts/common/` is NixOS-only (darwin hosts use `darwin/common/`), so no platform guard needed.

Add to the imports list in `hosts/common/default.nix` (line 9, after `./users`):

```nix
    ./keyd.nix
```

- [ ] **Step 3: Commit**

```bash
git add hosts/common/keyd.nix hosts/common/default.nix
git commit -m "feat: add keyd service for CapsLock→Ctrl, Ctrl→Hyper remapping on Linux"
```

### Task 7: Update Hyprland keybindings to use Hyper (MOD3)

**Files:**
- Modify: `home/features/desktop/hyprland.nix:68,188-259,176-178`

- [ ] **Step 1: Remove CapsLock remap from Hyprland input**

Replace line 68:

```nix
          kb_options = "ctrl:nocaps"; # CapsLock → Ctrl
```

With:

```nix
          kb_options = ""; # Key remapping handled by keyd (CapsLock→Ctrl, Ctrl→Hyper)
```

- [ ] **Step 2: Change mainMod from SUPER to MOD3**

Replace line 188:

```nix
        "$mainMod" = "SUPER";
```

With:

```nix
        "$mainMod" = "MOD3"; # Hyper key (physical Ctrl via keyd)
```

- [ ] **Step 3: Replace emacs-style focus/move bindings with arrow keys**

Replace lines 214-224 (the emacs-style focus and movement bindings):

```nix
          # Emacs-style focus navigation
          "CTRL ALT, B, movefocus, l"
          "CTRL ALT, F, movefocus, r"
          "CTRL ALT, P, movefocus, u"
          "CTRL ALT, N, movefocus, d"

          # Emacs-style window movement
          "CTRL ALT SHIFT, B, movewindow, l"
          "CTRL ALT SHIFT, F, movewindow, r"
          "CTRL ALT SHIFT, P, movewindow, u"
          "CTRL ALT SHIFT, N, movewindow, d"
```

With:

```nix
          # Window focus (arrow keys)
          "$mainMod, left, movefocus, l"
          "$mainMod, right, movefocus, r"
          "$mainMod, up, movefocus, u"
          "$mainMod, down, movefocus, d"

          # Window movement (arrow keys + shift)
          "$mainMod SHIFT, left, movewindow, l"
          "$mainMod SHIFT, right, movewindow, r"
          "$mainMod SHIFT, up, movewindow, u"
          "$mainMod SHIFT, down, movewindow, d"
```

- [ ] **Step 4: Add close-window binding**

Add after the fullscreen binding (line 196):

```nix
          "$mainMod, W, killactive"
```

- [ ] **Step 5: Import keybindings.nix and generate workspace assignments**

First, add `kb = import ./keybindings.nix;` to the `let` block in hyprland.nix (after line 14, alongside the other let bindings):

```nix
  kb = import ./keybindings.nix;
```

Then add a helper to generate windowrules from the shared workspace data (after the `rgba` helper):

```nix
  # Generate workspace assignment windowrules from shared keybindings module
  workspaceRules = lib.concatLists (lib.mapAttrsToList (ws: def:
    map (app: "workspace ${ws}, match:class ^(${app})$") def.linux
  ) kb.workspaces);
```

Then replace lines 176-178 (the hardcoded workspace assignments):

```nix
          "workspace 1, match:class ^(Emacs)$"
          "workspace 2, match:class ^(firefox)$"
          "workspace 3, match:class ^(code-url-handler)$" # VS Code
```

With a splice of the generated rules:

```nix
          # Workspace assignments (generated from keybindings.nix)
        ] ++ workspaceRules ++ [
```

Note: This splices the generated list into the middle of the `windowrule` list. The `] ++` closes the preceding literal list, appends `workspaceRules`, then `++ [` opens the next literal list for the remaining rules.

- [ ] **Step 6: Update the dropdown terminal comment**

Replace line 49:

```nix
          # Dropdown terminal: starts hidden in special workspace, toggled with Super+`
```

With:

```nix
          # Dropdown terminal: starts hidden in special workspace, toggled with Hyper+`
```

- [ ] **Step 7: Update file header comment**

Replace line 2:

```nix
# and ADR-004 (theme standardization).
```

With:

```nix
# and ADR-004 (theme standardization). WM keybindings use Hyper (MOD3 via keyd).
```

- [ ] **Step 8: Update the keybindings comment**

Replace lines 189-190:

```nix
        # Ctrl-focused bindings follow CUA conventions, Super controls the WM, and Emacs-style navigation
        # handles directional focus per ADR-003.
```

With:

```nix
        # Hyper (MOD3 via keyd) controls the WM. Arrow keys for directional focus.
        # CUA bindings (Ctrl via CapsLock) and Emacs navigation are unaffected.
```

- [ ] **Step 9: Fix unreachable screenshot bindings**

Most screenshot bindings use `$mainMod SHIFT` which works fine (Hyper+Shift). However, two bindings use `$mainMod CTRL` (lines 251-252) which becomes `MOD3 CTRL` — unreachable because physical Ctrl already sends MOD3, and the user can't press MOD3+CTRL simultaneously in a natural way.

Replace lines 251-252:

```nix
          "$mainMod CTRL, S, exec, $HOME/.local/bin/screenshot-area-annotate"
          "$mainMod CTRL, O, exec, $HOME/.local/bin/ocr-screenshot"
```

With (use Alt instead of Ctrl as secondary modifier):

```nix
          "$mainMod ALT, S, exec, $HOME/.local/bin/screenshot-area-annotate"
          "$mainMod ALT, O, exec, $HOME/.local/bin/ocr-screenshot"
```

Also note: `$mainMod, W` (close window, added in step 4) does not conflict with `$mainMod SHIFT, W` (wallpaper, line 207) — different modifier combos.

- [ ] **Step 10: Run `just check`**

Run: `just check`
Expected: No errors.

- [ ] **Step 11: Commit**

```bash
git add home/features/desktop/hyprland.nix
git commit -m "feat: migrate Hyprland keybindings from Super to Hyper (MOD3)"
```

---

## Chunk 4: Documentation Updates

### Task 8: Update ADR-003

**Files:**
- Modify: `docs/adr/ADR-003-keyboard-remapping-strategy.md`

- [ ] **Step 1: Update ADR-003**

Replace the entire file with:

```markdown
# ADR-003: Keyboard Remapping Strategy

**Status**: Superseded (updated 2026-03-15)
**Date**: 2025-01-13 (original), 2026-03-15 (revised)

## Context
Working across NixOS and macOS should feel consistent, especially for keyboard-driven workflows. Goals:
- Minimize friction when switching between platforms.
- Emacs-style keybindings (Ctrl) as the primary text/app modifier.
- Dedicated window manager modifier that conflicts with nothing.
- Platform-native app shortcuts (Cmd on macOS, Ctrl on Linux) for copy/paste.
- Keep muscle memory intact regardless of host.

## Decision (Revised)
1. **CapsLock → Ctrl**
   Emacs keybindings and CUA shortcuts use Ctrl, delivered via the CapsLock key (better ergonomics than corner Ctrl). Implemented by Karabiner on macOS and keyd on Linux.
2. **Physical Ctrl → Hyper (Ctrl+Alt+Cmd, no Shift)**
   Window management uses Hyper as a dedicated modifier. No app uses this three-modifier chord, so there are zero conflicts. Hyper excludes Shift so that Hyper+Shift combos work as distinct bindings.
3. **macOS remapping via Karabiner-Elements**
   `home/features/desktop/karabiner.nix` renders `karabiner.json`: CapsLock→Ctrl via `simple_modifications`, Ctrl→Hyper via `complex_modifications`.
4. **Linux remapping via keyd**
   `hosts/common/keyd.nix` configures the keyd daemon: CapsLock→Ctrl, Ctrl→Hyper (Mod3). Runs at evdev level before Hyprland.
5. **Window managers use Hyper**
   Aerospace (macOS) binds to `ctrl-alt-cmd`. Hyprland (Linux) binds to `MOD3`. Both consume `home/features/desktop/keybindings.nix` for shared workspace layout.
6. **Platform-native app shortcuts stay native**
   macOS apps use Cmd+C/V/X. Linux apps use Ctrl+C/V/X (via CapsLock). No cross-platform copy/paste remapping.

### Original Decision (Superseded)
The original strategy remapped Cmd→Ctrl on macOS so that all application shortcuts used Ctrl on both platforms. This worked but created conflicts when adding a tiling WM on macOS (Cmd/Super was needed for both app shortcuts and WM). The revised strategy introduces Hyper as a conflict-free WM modifier and returns macOS to native Cmd behavior.

## Consequences
**Positive**
- Three cleanly separated modifier namespaces: Ctrl (text/emacs), Hyper (WM), Cmd/Super (platform apps).
- Emacs bindings on CapsLock — better ergonomics than corner Ctrl.
- Identical WM keybindings on both platforms (Hyper+key).
- No app conflicts — Hyper is unused by all applications.

**Negative**
- macOS copy/paste uses Cmd (not Ctrl) — different physical key than Linux.
- CapsLock is lost (use Shift for caps).
- Physical Ctrl key no longer sends Ctrl — fully committed to Hyper.
- Muscle memory adjustment from previous Cmd→Ctrl scheme (~1-2 weeks).

See `docs/keyboard-layout-strategy.md` for detailed mapping tables.
```

- [ ] **Step 2: Commit**

```bash
git add docs/adr/ADR-003-keyboard-remapping-strategy.md
git commit -m "docs: update ADR-003 for Hyper-based keybinding strategy"
```

### Task 9: Update keyboard-layout-strategy.md

**Files:**
- Modify: `docs/keyboard-layout-strategy.md`

- [ ] **Step 1: Replace the full file**

```markdown
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
```

- [ ] **Step 2: Commit**

```bash
git add docs/keyboard-layout-strategy.md
git commit -m "docs: rewrite keyboard layout strategy for Hyper-based unified keybindings"
```

### Task 10: Final validation

- [ ] **Step 1: Run `just check`**

Run: `just check`
Expected: Clean pass with no errors across all changes.
