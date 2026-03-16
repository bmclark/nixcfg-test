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
