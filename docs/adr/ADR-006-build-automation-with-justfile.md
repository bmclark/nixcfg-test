# ADR-006: Build Automation with Justfile

**Status**: Accepted  
**Date**: 2025-01-13

## Context
Operating this configuration requires running a variety of verbose Nix and system commands:
- NixOS/nix-darwin rebuilds, tests, and builds
- Home-manager invocations
- Flake updates
- Garbage collection and store maintenance

Remembering raw commands like `sudo nixos-rebuild switch --flake .#carbon` or `darwin-rebuild switch --flake .#macmini` is error-prone. Options included shell scripts, Makefiles, Justfile recipes, or Nix-based apps.

## Decision
Standardize on a repository-level `justfile` that collects common workflows:
- NixOS recipes (`nixos-switch`, `nixos-test`, `nixos-boot`, `nixos-build`, `deploy-to`)
- Darwin recipes (`darwin-switch`, `darwin-test`, `darwin-build`)
- Home-manager recipes (`home-switch`, `home-switch-local`, `home-build`)
- Cross-platform helpers (`switch`, `test`, `build-all`)
- Update flow (`update`, `update-input`, `update-all`)
- Maintenance (`gc`, `gc-old`, `gc-all`, `optimize`, `clean`)
- Flake utilities (`check`, `show`)
- Git helpers (`commit`, `update-and-commit`, `deploy-update-commit`)
- Development shell entry (`dev-shell`, `dev`)

Users install `just` (e.g., `nix-shell -p just`) and then run short commands instead of memorizing full Nix invocations.

## Consequences
**Positive**
- Single entry point for all common workflows.
- `just --list` surfaces available commands with descriptions.
- Short, memorable commands reduce typos and friction.
- Platform-aware recipes encapsulate host-specific logic.
- Recipes compose cleanly (e.g., `update-all` chains other commands).
- Easier to document and extend than scattered shell scripts.

**Negative**
- Adds a dependency on the `just` binary.
- Another file to maintain alongside the configuration.
- Users still need to understand the underlying Nix operations eventually.

**Neutral**
- Comparable alternatives (Makefiles, shell scripts) remain viable but less ergonomic.
- Some recipes require sudo, so prompting persists.
- Commands reflect personal workflow; others might adapt or fork the justfile.
