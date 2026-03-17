---
status: Accepted
date: 2025-01-15
---

# ADR-007: Hyprland Configuration Modernization

## Context
The original Hyprland configuration for the `maverick` laptop was imported from an older setup and exhibited compatibility problems with current Hyprland releases. Deprecated window rule syntax mixed `windowrule` and `windowrulev2`, keybindings followed vim-style conventions that violated [ADR-003](ADR-003-keyboard-remapping-strategy.md), and the system lacked proper systemd integration. Essential Wayland services—hyprpaper, hypridle, wofi, and dunst—were only referenced through `exec-once`, leading to unreliable startup ordering. The wider Wayland ecosystem was also incomplete: no audio stack was configured despite the user belonging to the `audio` group, Bluetooth support was missing, and desktop niceties like automounting and polkit authentication prompts were absent. Visual polish lagged behind expectations (minimal blur, basic shadows, limited animations) and documentation was nonexistent.

Modern Hyprland releases (v0.48.0+) require updated configuration syntax, and contemporary Wayland workflows expect PipeWire audio, Bluetooth management, and a cohesive set of supporting services. Maintaining the repo-wide Dracula theme from [ADR-004](ADR-004-theme-standardization.md) also demanded better coordination across status bar, notifications, and launcher components. The goal was to deliver a refined, unix-porn aesthetic without sacrificing stability or maintainability.

## Decision
1. **Modernize decoration configuration** — Adopt nested `shadow` definitions, tuned blur parameters (size 6, passes 3, vibrancy 0.20), and rounding for a glass effect compatible with latest Hyprland syntax.
2. **Implement CUA/Emacs keybindings** — Replace vim-style bindings with Ctrl+W for close, Alt+Tab switching, Emacs-style directional focus (Ctrl+Alt+B/F/P/N), and continue using Super for window manager operations per ADR-003.
3. **Add Wayland ecosystem services** — Manage hyprpaper, hypridle, wofi, and dunst via home-manager services to improve reliability instead of launching them manually in `exec-once`.
4. **Add PipeWire audio system** — Enable PipeWire with PulseAudio and JACK compatibility, and integrate WirePlumber so Waybar can display and control volume state.
5. **Add Bluetooth support** — Enable BlueZ with experimental features for battery reporting, install Blueman for GUI management, and expose Bluetooth status through a Waybar module.
6. **Add desktop environment niceties** — Provide udisks2 automounting, polkit authentication dialogs, udiskie tray integration, and a Thunar setup with volume management plugins.
7. **Enhance Waybar** — Extend the bar with audio, network, battery, and Bluetooth modules while aligning styles with the Dracula palette.
8. **Update window rules** — Convert all legacy rules to the new Hyprland v2 syntax with explicit selectors (class:, title:, etc.) to avoid deprecation issues.
9. **Add systemd integration** — Export environment variables to user services so background daemons (hypridle, dunst) inherit the correct Wayland session context.
10. **Improve aesthetics** — Introduce custom bezier curves, animation profiles, soft shadows, and layer blur rules to deliver the desired unix-porn vibe.
11. **Comprehensive documentation** — Add inline comments and repository guides that explain configuration philosophy, troubleshooting steps, and customization paths.

## Consequences
**Positive**
- Configuration remains compatible with modern Hyprland releases.
- Keyboard shortcuts match ADR-003 and feel consistent across NixOS and macOS.
- Wayland services start reliably via systemd instead of ad-hoc shell commands.
- PipeWire delivers lower-latency audio with better Bluetooth support.
- Bluetooth devices expose battery readouts and have a friendly GUI manager.
- Desktop niceties (automounting, authentication prompts) behave predictably.
- Visual design matches unix-porn expectations while staying on brand with Dracula colors.
- Documentation ensures future contributors can reason about and extend the setup.

**Negative**
- Users accustomed to vim-style bindings must adjust muscle memory.
- Heavier blur and animation settings increase GPU usage (tunable if needed).
- Additional background services (hypridle, udiskie, polkit agent) consume resources.
- PipeWire adoption may require retuning audio settings for certain applications.

**Neutral**
- Managing hyprpaper and hypridle as services is a different pattern but more robust.
- Layer blur rules may need tweaks for alternative bars or launchers.
- WirePlumber replaces PulseAudio tooling; workflows change but functionality remains.
- Wallpaper paths stay user-specific and require manual customization.

## References
- [ADR-003: Keyboard Remapping Strategy](ADR-003-keyboard-remapping-strategy.md)
- [ADR-004: Theme Standardization](ADR-004-theme-standardization.md)
- Hyprland Wiki — configuration syntax and animation options
- Home Manager manual — wayland.* and services.* modules
- NixOS Wiki — PipeWire, Bluetooth, and desktop service configuration
