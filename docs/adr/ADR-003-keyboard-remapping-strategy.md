# ADR-003: Keyboard Remapping Strategy

**Status**: Accepted  
**Date**: 2025-01-13

## Context
Working across NixOS and macOS should feel consistent, especially for keyboard-driven workflows. Goals:
- Minimize friction when switching between platforms.
- Prefer Linux/Windows conventions (Ctrl-driven shortcuts) over macOS defaults.
- Avoid conflicts between window manager bindings and application shortcuts.
- Preserve Emacs-style bindings that rely heavily on Ctrl.
- Keep muscle memory intact regardless of host.

Out of the box, macOS leans on Cmd for application shortcuts, while Linux WMs commonly reserve Super for window management. A coordinated remapping strategy is required to reconcile the two.

## Decision
1. **Application shortcuts use Ctrl**  
   Copy, paste, tab management, save, and Emacs navigation leverage Ctrl everywhere.
2. **Window manager shortcuts use Super**  
   Hyprland bindings (`$mainMod = "SUPER"`) handle launching, closing, moving, and focusing windows via Super-based combos.
3. **macOS remapping via Karabiner-Elements**  
   - `darwin/common/karabiner.nix` enables the Karabiner service.  
   - `home/features/desktop/karabiner.nix` renders the `karabiner.json` user profile that maps Cmd → Ctrl (both left and right).  
   - Users may need to adjust a few macOS system shortcuts manually.
4. **Hyprland configuration stays unchanged**  
   Existing bindings already align with the Super-for-WM pattern and integrate Dracula styling.

See `docs/keyboard-layout-strategy.md` for detailed mapping tables and rationale.

## Consequences
**Positive**
- Uniform muscle memory across platforms.
- Clean separation between application and window manager shortcuts avoids collisions.
- Emacs bindings operate identically everywhere.
- Super key gains focused use for window management.

**Negative**
- Breaks native macOS expectations; retraining is needed for Cmd-centric users.
- Karabiner affects all macOS apps, which might surprise other users of the same machine.
- Some macOS system shortcuts require manual tweaks after remapping.
- Requires Accessibility and Input Monitoring permissions on macOS.

**Neutral**
- Initial adjustment period when adopting the new scheme.
- Certain applications may warrant Karabiner exceptions later.
- Linux users experience no change—Hyprland already followed the convention.
