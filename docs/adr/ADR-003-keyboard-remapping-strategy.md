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
   `home/features/desktop/karabiner.nix` renders `karabiner.json`: CapsLock→Ctrl and Ctrl→Hyper are both implemented as ordered `complex_modifications` so CapsLock is consumed before the Hyper mapping.
4. **Linux remapping via keyd**
   `hosts/common/keyd.nix` configures the keyd daemon: CapsLock→Ctrl, Ctrl→Hyper (Mod3). Runs at evdev level before Hyprland.
5. **Window managers use Hyper**
   Aerospace (macOS) binds to `ctrl-alt-cmd`. Hyprland (Linux) binds to `MOD3`. Both consume `home/features/desktop/keybindings.nix` for shared workspace layout.
6. **Cross-platform Cmd+C/V/X/Z via keyd super_cua layer**
   macOS apps use native Cmd+C/V/X/Z. On Linux, keyd's `super_cua` layer translates `Super+C/V/X/Z` → `Ctrl+C/V/X/Z`, so the same physical key (`Cmd`/`Super`) does copy/paste/undo on both platforms. Emacs uses CUA mode to handle the translated `C-c`/`C-x` contextually (copy/cut with active region, Emacs prefix otherwise). On macOS, Emacs receives raw Super and uses dedicated `s-` keybindings.

### Original Decision (Superseded)
The original strategy remapped Cmd→Ctrl on macOS so that all application shortcuts used Ctrl on both platforms. This worked but created conflicts when adding a tiling WM on macOS (Cmd/Super was needed for both app shortcuts and WM). The revised strategy introduces Hyper as a conflict-free WM modifier and returns macOS to native Cmd behavior.

## Consequences
**Positive**
- Three cleanly separated modifier namespaces: Ctrl (text/emacs), Hyper (WM), Cmd/Super (platform apps).
- Emacs bindings on CapsLock — better ergonomics than corner Ctrl.
- Identical WM keybindings on both platforms (Hyper+key).
- No app conflicts — Hyper is unused by all applications.

**Negative**
- CapsLock is lost (use Shift for caps).
- Physical Ctrl key no longer sends Ctrl — fully committed to Hyper.
- Muscle memory adjustment from previous Cmd→Ctrl scheme (~1-2 weeks).
- keyd's super_cua layer cannot exclude per-app on Hyprland (keyd-application-mapper doesn't support it). CUA mode in Emacs is the workaround.

See `docs/keyboard-layout-strategy.md` for detailed mapping tables.
