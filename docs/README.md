# nixcfg Documentation

This repository contains the NixOS and nix-darwin configuration that manages a NixOS laptop (`carbon`) and a macOS Mac Mini (`macmini`) using home-manager integration.

## Repository Structure
- `flake.nix` - Main flake defining system and home-manager configurations
- `justfile` - Build automation commands (see Quick Start below)
- `hosts/` - NixOS system configurations (`carbon` laptop)
- `darwin/` - macOS system configurations (`macmini`)
- `home/` - Home-manager configurations
  - `bclark/` - User-specific configs (`carbon.nix`, `macmini.nix`, `home.nix`, `dotfiles/`)
  - `features/` - Modular feature configurations (`cli/`, `desktop/`, `development/`, `editors/`)
  - `common/` - Shared home-manager settings
  - `themes/` - Theme definitions (`dracula.nix`)
- `docs/` - Documentation (you are here)
  - `adr/` - Architecture Decision Records

## Quick Links
- [System User Guide](system-user-guide.md)
- [Architecture Decision Records](adr/)
- [Keyboard Shortcut Conflicts](keyboard-shortcut-conflicts.md)
- [Keyboard Layout Strategy](keyboard-layout-strategy.md)
- [Dotfiles Migration Strategy](dotfiles-migration.md)
- [Quick Start Guide](../README.md#quick-start)

## Feature Module System
Feature modules live in `home/features/` and follow a consistent pattern:
- Organized by category (`cli`, `desktop`, `development`, `editors`)
- Each feature exposes an enable option `features.<category>.<feature>.enable`
- User configs (`home/bclark/carbon.nix`, `home/bclark/macmini.nix`) toggle features per host
- Platform guards (`pkgs.stdenv.isLinux`, `pkgs.stdenv.isDarwin`) keep modules cross-platform friendly

Example: enabling zsh in `home/bclark/carbon.nix`

```nix
features.cli.zsh.enable = true;
```

## Platform Support
- **carbon** (NixOS laptop): Hyprland desktop, development tooling, Dracula theme throughout
- **macmini** (macOS): nix-darwin managed system, Homebrew integration, Karabiner remapping
- Shared feature modules keep CLI tools, editors, and development experience consistent

## Key Technologies
- NixOS and nix-darwin for declarative system configuration
- home-manager integrated as modules for user environments
- Hyprland window manager (NixOS)
- Ghostty terminal emulator (both platforms)
- zsh shell with Starship prompt (temporary until Powerlevel10k migration)
- Emacs with Dracula theme
- Karabiner-Elements for macOS keyboard remapping
- Switchable themes (Dracula, Tokyo Night) in `home/themes/`
- Declarative Homebrew management for macOS apps via `darwin/common/homebrew.nix`

## For More Details
Explore the [ADR directory](adr/) for detailed architectural decisions and rationale behind the configuration choices.
