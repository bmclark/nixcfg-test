# ADR-014: macOS Platform Parity Strategy

**Date:** 2026-03-15
**Status:** Accepted

## Context

The macmini (macOS/nix-darwin) and carbon (NixOS) share extensive home-manager config for CLI tools, editors, themes, and dev tooling. However, several platform-specific gaps existed:

- Emacs daemon used systemd (Linux-only)
- Some zsh functions used Wayland tools (wl-copy, Wayland screenshot tools)
- Chromium isn't packaged for aarch64-darwin
- `homebrew.nix` declared almost nothing despite `onActivation.cleanup = "zap"` being set
- gpg-agent used `pinentry-curses` on both platforms instead of the native macOS keychain UI

## Decision

### Package management hierarchy

Prefer nix > Homebrew > Mac App Store > manual install:

1. **Nix (home-manager):** All CLI tools, editors, dev tooling, fonts — shared config with Linux
2. **Homebrew casks:** Apps that need macOS system integration or lack nixpkgs macOS builds (Ghostty, Karabiner, Raycast, etc.)
3. **Homebrew formulae:** CLI tools not in nixpkgs (mas, gemini-cli, tdd-guard)
4. **Mac App Store (via mas):** Apps only available through MAS (Bitwarden, iWork suite, Xcode)
5. **Manual install:** Only for apps that can't be managed by any of the above (driver utilities)

### Homebrew zap strategy

`onActivation.cleanup = "zap"` removes anything not declared in `darwin/common/homebrew.nix`. Any new brew, cask, or MAS app **must** be added to `homebrew.nix` before running `darwin-switch`, or it will be deleted.

### Platform guard patterns

- **Chromium:** `config = mkIf (cfg.enable && pkgs.stdenv.isLinux)` — silently disabled on macOS, replaced by Google Chrome cask
- **Emacs daemon:** `services.emacs` (systemd) on Linux, `launchd.agents.emacs` on macOS
- **Zsh clipboard:** `cpath` uses Nix interpolation to select `pbcopy` (Darwin) or `wl-copy` (Linux)
- **OCR functions:** `lib.optionalString pkgs.stdenv.isLinux` — Linux-only until macOS equivalents are implemented
- **gpg-agent pinentry:** `pinentry_mac` on Darwin for native keychain UI, `pinentry-curses` on Linux
- **Ghostty:** nixpkgs on Linux, Homebrew cask on macOS — shared config file via `home.file`

### macOS system defaults

`darwin/macmini/configuration.nix` sets developer-focused defaults: Dark mode, fast key repeat, disabled auto-correct and smart quotes, tap-to-click trackpad, firewall enabled, screenshots to `~/Pictures/Screenshots`.

## Consequences

- Both hosts now produce a consistent terminal + editor experience
- All installed macOS software is captured declaratively
- Platform-specific features degrade gracefully (disabled, not erroring)
- Adding macOS software requires updating `homebrew.nix` — enforced by zap
- OCR on macOS is deferred until native alternatives are implemented
