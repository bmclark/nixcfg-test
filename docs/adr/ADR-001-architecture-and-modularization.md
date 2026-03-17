# ADR-001: Architecture and Modularization Strategy

**Status**: Accepted  
**Date**: 2025-01-13

## Context
Managing configurations for multiple systems (NixOS laptop and macOS Mac Mini) with different requirements but shared tooling demands an approach that:
- Supports multiple hosts spanning distinct operating systems
- Allows selective feature enablement per host
- Minimizes code duplication while staying maintainable
- Simplifies onboarding new machines in the future
- Keeps system-level and user-level configuration clearly separated
- Enables cross-platform feature modules that work on both NixOS and macOS

Traditional monolithic configuration files become unwieldy and obscure what is enabled on each system.

## Decision
Adopt a feature-based modular architecture with these pillars:
1. **Platform separation**: Dedicated directories for NixOS (`hosts/`) and macOS (`darwin/`) system configurations.
2. **Feature modules**: User configuration split into categorized modules under `home/features/cli`, `desktop`, `development`, and `editors`.
3. **Enable pattern**: Each feature defines `options.features.<category>.<feature>.enable = lib.mkEnableOption "...";` and gates configuration behind `lib.mkIf cfg.enable`, adding platform guards (`pkgs.stdenv.isLinux`, `pkgs.stdenv.isDarwin`) as needed.
4. **User configuration**: Host-specific files (`home/bclark/maverick.nix`, `home/bclark/iceman.nix`) import feature modules and toggle them per host.
5. **Common configuration**: Shared logic centralized in `hosts/common/`, `darwin/common/`, and `home/common/`.
6. **Home-manager integration**: Home-manager runs as a module in both NixOS and nix-darwin with `useGlobalPkgs = true; useUserPackages = true;`.
7. **Dotfiles strategy**: Placeholder modules in `home/bclark/dotfiles/` bridge to the external dotfiles repository (see `docs/dotfiles-migration.md`).

This design is implemented in `flake.nix`, modules such as `home/features/cli/zsh.nix`, and host configs like `home/bclark/maverick.nix`.

## Consequences
**Positive**
- Clear separation of concerns; each module focuses on a single feature.
- Hosts enable only what they need, reducing drift.
- Feature modules are reusable across platforms.
- Discoverability improves—browse `home/features/` to understand capabilities.
- Maintains modularity as the configuration grows.
- Cross-platform support emerges naturally via platform guards.
- Leverages the Nix module system for validation and type checking.

**Negative**
- Higher upfront complexity for newcomers to the module system.
- More files to manage compared to a monolithic setup.
- Requires tracing from host config to feature module to grasp full behavior.

**Neutral**
- Discipline is required to keep new features aligned with the pattern.
- Future contributors must understand the established structure before extending it.
