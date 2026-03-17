# macOS System Defaults Round 2 — Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix screen sharing (replace ARD with plain VNC), add dock/finder/power/hot corner defaults, disable Mission Control for Aerospace, add FileVault status check.

**Architecture:** All changes are edits to existing nix-darwin config files. The screen sharing module in `darwin/common/default.nix` gets reworked to use `launchctl` instead of ARD `kickstart`. System defaults expand in `darwin/macmini/configuration.nix`. No new files.

**Tech Stack:** nix-darwin, home-manager, Nix

**Spec:** Interview notes from conversation (no separate spec doc — scope was defined interactively).

---

## Chunk 1: Fix Screen Sharing Module

### Task 1: Replace ARD kickstart with plain Screen Sharing

**Files:**
- Modify: `darwin/common/default.nix:65-80` (screen sharing activation script)

The current module uses ARD `kickstart` commands which enable Remote Management, not plain Screen Sharing. These are mutually exclusive on macOS. For VNC access from a Linux laptop (Remmina), we need the `com.apple.screensharing` launchd service, not ARD.

- [ ] **Step 1: Replace the activation script**

In `darwin/common/default.nix`, replace the `mkIf screenSharingCfg.enable` block's activation script. Change:

```nix
      system.activationScripts.postActivation.text = mkAfter ''
        echo "configuring macOS Screen Sharing for ${allowedScreenSharingUsersCsv}" >&2
        ${kickstart} -activate
        ${kickstart} -configure -access -on -users ${escapeShellArg allowedScreenSharingUsersCsv} -privs -all
        ${kickstart} -configure -allowAccessFor -specifiedUsers
        ${kickstart} -restart -agent -console
      '';
```

To:

```nix
      system.activationScripts.postActivation.text = mkAfter ''
        echo "configuring macOS Screen Sharing for ${allowedScreenSharingUsersCsv}" >&2

        # Disable Remote Management (ARD) — mutually exclusive with Screen Sharing
        ${kickstart} -deactivate -configure -access -off 2>/dev/null || true

        # Enable plain Screen Sharing (VNC on port 5900)
        /bin/launchctl enable system/com.apple.screensharing 2>/dev/null || true
        /bin/launchctl bootstrap system /System/Library/LaunchDaemons/com.apple.screensharing.plist 2>/dev/null || true

        # Restrict access to specified users via dscl
        for user in ${escapeShellArgs allowedScreenSharingUsers}; do
          /usr/bin/dscl . -merge /Groups/com.apple.access_screensharing GroupMembership "$user"
        done
      '';
```

Note: Use `escapeShellArgs` (plural) against the `allowedScreenSharingUsers` list, not `escapeShellArg` against the CSV string. This ensures each user is individually quoted and the `for` loop iterates correctly with multiple users.

- [ ] **Step 2: Remove unused kickstart variable if no longer needed**

Check if `kickstart` is still referenced after the change. Since we still use it for `-deactivate`, keep the `kickstart` binding in the `let` block.

- [ ] **Step 3: Run `just check` to validate**

Run: `just check`
Expected: No errors.

- [ ] **Step 4: Commit**

```bash
git add darwin/common/default.nix
git commit -m "fix: use plain Screen Sharing (VNC) instead of ARD Remote Management"
```

## Chunk 2: System Defaults Expansion

### Task 2: Add Dock defaults (scale effect, minimize-to-app, hot corners)

**Files:**
- Modify: `darwin/macmini/configuration.nix:44-51` (dock block)

- [ ] **Step 1: Expand the dock block**

In `darwin/macmini/configuration.nix`, add to the existing `dock = { ... }` block:

```nix
      mineffect = "scale";
      minimize-to-application = true;
      # Hot corners (0=disabled, 4=desktop, 10=display sleep, 13=lock screen, 14=quick note)
      wvous-tl-corner = 13; # Lock Screen
      wvous-tr-corner = 14; # Quick Note
      wvous-bl-corner = 4;  # Desktop
      wvous-br-corner = 10; # Display Sleep
```

- [ ] **Step 2: Run `just check`**

Run: `just check`
Expected: No errors.

- [ ] **Step 3: Commit**

```bash
git add darwin/macmini/configuration.nix
git commit -m "feat: add dock defaults (scale effect, minimize-to-app, hot corners)"
```

### Task 3: Add Finder defaults (home window, disable extension warning, desktop icons)

**Files:**
- Modify: `darwin/macmini/configuration.nix:52-58` (finder block)

- [ ] **Step 1: Expand the finder block**

Add to the existing `finder = { ... }` block:

```nix
      NewWindowTarget = "PfHm"; # New windows open to home
      FXEnableExtensionChangeWarning = false;
      ShowExternalHardDrivesOnDesktop = true;
      ShowRemovableMediaOnDesktop = true;
      ShowMountedServersOnDesktop = true;
      FXDefaultSearchScope = "SCcf"; # Search current folder by default
      _FXSortFoldersFirst = true;
```

- [ ] **Step 2: Run `just check`**

Run: `just check`
Expected: No errors.

- [ ] **Step 3: Commit**

```bash
git add darwin/macmini/configuration.nix
git commit -m "feat: add finder defaults (home window, extension warning, desktop icons)"
```

### Task 4: Add power management settings

**Files:**
- Modify: `darwin/macmini/configuration.nix` (add new top-level `power` block)

- [ ] **Step 1: Add power block**

Add after the `system.startup.chime = false;` line:

```nix
  power = {
    restartAfterPowerFailure = true;
    restartAfterFreeze = true;
    sleep = {
      computer = 0;  # Never sleep (always-on Mac Mini)
      display = 60;  # Display sleeps after 60 minutes
      harddisk = 0;  # Never spin down
    };
  };
```

- [ ] **Step 2: Run `just check`**

Run: `just check`
Expected: No errors.

- [ ] **Step 3: Commit**

```bash
git add darwin/macmini/configuration.nix
git commit -m "feat: add power management (never sleep, display 60min, auto-restart)"
```

### Task 5: Disable Mission Control for Aerospace + disable .DS_Store on network volumes

**Files:**
- Modify: `darwin/macmini/configuration.nix` (CustomUserPreferences block and trackpad block)

- [ ] **Step 1: Expand CustomUserPreferences**

Replace the existing `CustomUserPreferences` block with:

```nix
    CustomUserPreferences = {
      "com.apple.screensaver" = {
        idleTime = 900;
      };
      "com.apple.desktopservices" = {
        DSDontWriteNetworkStores = true;
        DSDontWriteUSBStores = true;
      };
      # Disable Mission Control keyboard shortcuts (Aerospace owns window management)
      "com.apple.symbolichotkeys" = {
        AppleSymbolicHotKeys = {
          # Mission Control (Ctrl+Up / F3)
          "32" = { enabled = false; };
          "34" = { enabled = false; };
          # Application Windows (Ctrl+Down)
          "33" = { enabled = false; };
          "35" = { enabled = false; };
          # Move left a space (Ctrl+Left / fn variant)
          "79" = { enabled = false; };
          "80" = { enabled = false; };
          # Move right a space (Ctrl+Right / fn variant)
          "81" = { enabled = false; };
          "82" = { enabled = false; };
          # Switch to Desktop 1-6 (Ctrl+1 through Ctrl+6)
          "118" = { enabled = false; };
          "119" = { enabled = false; };
          "120" = { enabled = false; };
          "121" = { enabled = false; };
          "122" = { enabled = false; };
          "123" = { enabled = false; };
        };
      };
    };
    WindowManager = {
      GloballyEnabled = false; # Disable Stage Manager
    };
```

- [ ] **Step 2: Disable Mission Control trackpad gestures**

Add to the existing `trackpad = { ... }` block:

```nix
      TrackpadThreeFingerVertSwipeGesture = 0;
```

- [ ] **Step 3: Run `just check`**

Run: `just check`
Expected: No errors.

- [ ] **Step 4: Commit**

```bash
git add darwin/macmini/configuration.nix
git commit -m "feat: disable Mission Control, Stage Manager, .DS_Store on network/USB"
```

### Task 6: Add FileVault status check to activation script

**Files:**
- Modify: `darwin/macmini/configuration.nix` (add activation script)

- [ ] **Step 1: Add FileVault status reporting**

Add after the `power` block:

First, ensure `lib` is in the module arguments. Change the file header from `{pkgs, ...}:` to `{pkgs, lib, ...}:`.

Then add after the `power` block:

```nix
  system.activationScripts.postActivation.text = lib.mkAfter ''
    echo "--- FileVault status ---" >&2
    /usr/bin/fdesetup status >&2
    echo "------------------------" >&2
  '';
```

Must use `lib.mkAfter` to avoid conflicting with the screen sharing activation script in `darwin/common/default.nix` which also sets `postActivation.text` with `mkAfter`. Both will be concatenated by nix-darwin's `types.lines` merge.

This prints FileVault status during every `darwin-switch` so the user sees if it's enabled or not. It does not attempt to enable/disable — that's a one-time manual step (`sudo fdesetup enable`).

- [ ] **Step 2: Run `just check`**

Run: `just check`
Expected: No errors.

- [ ] **Step 3: Commit**

```bash
git add darwin/macmini/configuration.nix
git commit -m "feat: report FileVault status during darwin-switch activation"
```

## Chunk 3: Documentation

### Task 7: Update mac-parity-todo.md with new deferred items

**Files:**
- Modify: `docs/mac-parity-todo.md`

- [ ] **Step 1: Add completed and deferred items**

Replace contents with:

```markdown
# macOS Parity — Deferred Work

Items outside the terminal + editors focus of the initial parity work (ADR-014).

## Completed

- [x] **Tailscale:** added `tailscale` cask to `homebrew.nix`
- [x] **pueue:** added `lib.mkIf pkgs.stdenv.isLinux` guard for systemd service
- [x] **fontconfig:** verified `fonts.fontconfig` works cross-platform via home-manager (no guard needed)
- [x] **macOS-native OCR:** skipped — macOS Live Text (built into Preview, Quick Look, Screenshot) covers this natively
- [x] **Screen Sharing:** replaced ARD Remote Management with plain VNC Screen Sharing for Linux Remmina access
- [x] **Dock defaults:** scale effect, minimize-to-application, hot corners (lock/note/desktop/sleep)
- [x] **Finder defaults:** home window, disable extension warning, show desktop icons, search current folder
- [x] **Power management:** never sleep, display 60min, auto-restart after power failure
- [x] **Mission Control:** disabled gestures and keyboard shortcuts for Aerospace
- [x] **Stage Manager:** disabled
- [x] **.DS_Store:** disabled on network and USB volumes
- [x] **FileVault:** status check during darwin-switch

## Deferred

- [ ] **Multi-monitor AeroSpace config**
- [ ] **Backup strategy:** restic or borgbackup
- [ ] **Secure Boot:** lanzaboote on NixOS
```

- [ ] **Step 2: Commit**

```bash
git add docs/mac-parity-todo.md
git commit -m "docs: update mac-parity-todo with round 2 completions and remaining deferred items"
```

### Task 8: Final validation

- [ ] **Step 1: Run `just check` to confirm everything passes**

Run: `just check`
Expected: Clean pass.
