# macOS System Preferences & Parity Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Expand macOS system defaults and close out mac-parity-todo items.

**Architecture:** All changes are declarative nix-darwin or home-manager config edits. No new files created — only modifications to existing config files and a todo doc update.

**Tech Stack:** nix-darwin, home-manager, Nix

**Spec:** `docs/superpowers/specs/2026-03-15-macos-system-prefs-and-parity-design.md`

---

## Chunk 1: System Preferences & Parity

### Task 1: Expand system.defaults in darwin/macmini/configuration.nix

**Files:**
- Modify: `darwin/macmini/configuration.nix:22-57` (system.defaults block)

- [ ] **Step 1: Add Menu Bar / Control Center settings**

Add after the existing `system.defaults = {` block opening, inside the block. Insert these new sections after the existing `screencapture` block (line 56) but before the closing `};` on line 57:

```nix
    # --- Menu Bar / Control Center ---
    menuExtraClock = {
      Show24Hour = false;
      ShowAMPM = true;
      ShowDate = true;
      ShowDayOfWeek = true;
    };
    controlcenter = {
      BatteryShowPercentage = true;
      Bluetooth = true;
      Sound = true;
    };
```

- [ ] **Step 2: Add Login & Security settings**

Add after the controlcenter block:

```nix
    # --- Login & Security ---
    screensaver = {
      askForPassword = true;
      askForPasswordDelay = 60;
    };
```

- [ ] **Step 3: Add Sound settings to NSGlobalDomain and system.startup**

Add to the existing `NSGlobalDomain` block (after line 32, before the closing `};`):

```nix
      # Sound
      "com.apple.sound.beep.feedback" = 0;
      "com.apple.sound.beep.volume" = 0.0;
```

Add as a new top-level setting after the `system.defaults` block closes (after line 57):

```nix
  system.startup.chime = false;
```

- [ ] **Step 4: Add UX Polish settings to NSGlobalDomain**

Add to the existing `NSGlobalDomain` block:

```nix
      # UX Polish
      NSTableViewDefaultSizeMode = 2; # Sidebar icon size: medium
      AppleShowScrollBars = "Always";
      NSNavPanelExpandedStateForSaveMode = true;
      NSNavPanelExpandedStateForSaveMode2 = true;
      PMPrintingExpandedStateForPrint = true;
      PMPrintingExpandedStateForPrint2 = true;
```

- [ ] **Step 5: Add LaunchServices and CustomUserPreferences**

Add new sections inside `system.defaults`:

```nix
    LaunchServices = {
      LSQuarantine = false; # Disable "Are you sure?" for downloaded apps
    };
    CustomUserPreferences = {
      "com.apple.screensaver" = {
        idleTime = 900; # 15 minutes
      };
    };
```

- [ ] **Step 6: Run `just check` to validate**

Run: `just check`
Expected: No errors related to the new system.defaults options.

- [ ] **Step 7: Commit**

```bash
git add darwin/macmini/configuration.nix
git commit -m "feat: expand macOS system defaults (menu bar, security, sound, UX)"
```

### Task 2: Add Tailscale cask to homebrew.nix

**Files:**
- Modify: `darwin/common/homebrew.nix:18-29` (casks list)

- [ ] **Step 1: Add tailscale cask**

Add `"tailscale"` to the casks list in alphabetical order (after `"spotify"`):

```nix
      "tailscale" # VPN mesh network (menu bar app)
```

- [ ] **Step 2: Run `just check` to validate**

Run: `just check`
Expected: No errors.

- [ ] **Step 3: Commit**

```bash
git add darwin/common/homebrew.nix
git commit -m "feat: add tailscale cask for macOS menu bar VPN"
```

### Task 3: Add platform guard for pueue service

**Files:**
- Modify: `home/features/cli/default.nix:221-229` (services.pueue block)

- [ ] **Step 1: Wrap pueue service with Linux guard**

Replace the pueue block at lines 221-229:

```nix
  # --- Pueue task queue daemon ------------------------------------------------
  services.pueue = {
    enable = true;
    settings = {
      shared = {
        default_parallel_tasks = 2;
      };
    };
  };
```

With:

```nix
  # --- Pueue task queue daemon (systemd — Linux only) -------------------------
  services.pueue = lib.mkIf pkgs.stdenv.isLinux {
    enable = true;
    settings = {
      shared = {
        default_parallel_tasks = 2;
      };
    };
  };
```

- [ ] **Step 2: Run `just check` to validate**

Run: `just check`
Expected: No errors. The pueue service will no longer be evaluated on Darwin.

- [ ] **Step 3: Commit**

```bash
git add home/features/cli/default.nix
git commit -m "fix: guard pueue service behind Linux (systemd not available on Darwin)"
```

### Task 4: Update mac-parity-todo.md

**Files:**
- Modify: `docs/mac-parity-todo.md`

- [ ] **Step 1: Update the todo list**

Replace the entire contents with:

```markdown
# macOS Parity — Deferred Work

Items outside the terminal + editors focus of the initial parity work (ADR-014).

## Completed

- [x] **Tailscale:** added `tailscale` cask to `homebrew.nix`
- [x] **pueue:** added `lib.mkIf pkgs.stdenv.isLinux` guard for systemd service
- [x] **fontconfig:** verified `fonts.fontconfig` works cross-platform via home-manager (no guard needed)
- [x] **macOS-native OCR:** skipped — macOS Live Text (built into Preview, Quick Look, Screenshot) covers this natively
```

- [ ] **Step 2: Commit**

```bash
git add docs/mac-parity-todo.md
git commit -m "docs: update mac-parity-todo with completed items"
```

### Task 5: Final validation

- [ ] **Step 1: Run `just check` to confirm all changes pass together**

Run: `just check`
Expected: Clean pass with no errors.
