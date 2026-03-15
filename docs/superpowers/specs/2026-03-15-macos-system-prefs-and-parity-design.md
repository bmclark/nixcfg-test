# macOS System Preferences & Parity Cleanup

**Date:** 2026-03-15
**Status:** Approved

## Goal

Expand macOS system defaults in the darwin configuration and close out remaining mac-parity-todo items (excluding OCR, which is covered natively by macOS Live Text).

## Changes

### 1. `darwin/macmini/configuration.nix` — Expand `system.defaults`

#### Menu Bar / Control Center
- Clock: 12-hour format, show date
- Battery percentage: shown
- Bluetooth icon: shown in menu bar
- Sound icon: shown in menu bar

#### Login & Security
- Require password 1 minute after sleep/screensaver
- Screensaver activation: 15 minutes idle

#### Sound
- Startup chime: disabled (`system.startup.chime = false`)
- UI sound effects: disabled (`"com.apple.sound.beep.feedback" = 0`)
- Alert volume: 0 (`"com.apple.sound.beep.volume" = 0.0`)

#### Nix-darwin option mapping
```nix
# Menu Bar
system.defaults.menuExtraClock.Show24Hour = false;
system.defaults.menuExtraClock.ShowAMPM = true;
system.defaults.menuExtraClock.ShowDate = true;  # not an int
system.defaults.menuExtraClock.ShowDayOfWeek = true;
system.defaults.controlcenter.BatteryShowPercentage = true;
system.defaults.controlcenter.Bluetooth = true;
system.defaults.controlcenter.Sound = true;

# Login & Security
system.defaults.screensaver.askForPassword = true;
system.defaults.screensaver.askForPasswordDelay = 60;

# Sound
system.startup.chime = false;
system.defaults.NSGlobalDomain."com.apple.sound.beep.feedback" = 0;
system.defaults.NSGlobalDomain."com.apple.sound.beep.volume" = 0.0;

# UX Polish
system.defaults.NSGlobalDomain.NSTableViewDefaultSizeMode = 2;
system.defaults.NSGlobalDomain.AppleShowScrollBars = "Always";
system.defaults.NSGlobalDomain.NSQuitAlwaysKeepsWindows = true;
system.defaults.NSGlobalDomain.NSNavPanelExpandedStateForSaveMode = true;
system.defaults.NSGlobalDomain.NSNavPanelExpandedStateForSaveMode2 = true;
system.defaults.NSGlobalDomain.PMPrintingExpandedStateForPrint = true;
system.defaults.NSGlobalDomain.PMPrintingExpandedStateForPrint2 = true;
system.defaults.LaunchServices.LSQuarantine = false;
```

#### General UX Polish
- Sidebar icon size: medium (2)
- Scroll bars: always visible
- Close windows when quitting: disabled (resume on relaunch)
- Expand save panel by default
- Expand print panel by default
- Disable GateKeeper first-launch dialog

### 2. `darwin/common/homebrew.nix` — Add `tailscale` cask

Add `"tailscale"` to the casks list for the macOS menu bar VPN app.

### 3. `home/features/cli/default.nix` — Platform guard for pueue service

The `services.pueue` block uses systemd under the hood in home-manager, which is unavailable on Darwin. Wrap the service enable with `lib.mkIf pkgs.stdenv.isLinux`. The pueue package itself remains cross-platform.

### 4. `home/features/desktop/fonts.nix` — Fontconfig check

`fonts.fontconfig` is a home-manager option that writes to `~/.config/fontconfig/` — it works cross-platform. No guard needed. Verify during `just check` and remove from todo.

### 5. `docs/mac-parity-todo.md` — Update

- Remove Tailscale item (completed)
- Remove pueue item (completed)
- Remove fontconfig item (completed)
- Remove OCR item (skipped — native macOS Live Text covers this)

## Out of Scope

- Window management (spaces, hot corners, stage manager)
- Keybindings / keyboard remapping
- Mouse/trackpad tuning (already configured)
- Accessibility settings (user prefers defaults: keep motion, keep transparency, no increased contrast)
- macOS OCR wrappers (native Live Text is sufficient)

## Validation

- `just check` must pass after all changes
- `just darwin-switch` to apply (or at minimum `just check` if not on macmini)
