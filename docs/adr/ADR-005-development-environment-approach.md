# ADR-005: Development Environment Approach

**Status**: Accepted  
**Date**: 2025-01-13

## Context
Projects across languages (Python, Rust, Go, Node.js, etc.) require heterogeneous toolchains. Installing every tool globally leads to:
- Version conflicts between projects
- Bloated system configurations
- Difficulty reproducing builds on other machines

The goal is to keep the system lean while making it easy for projects to declare their own dependencies. Options considered included global installs, per-project `nix-shell`, `direnv`, or container-based workflows.

## Decision
Adopt per-project Nix shells (`shell.nix` or flake-based `devShells`) for development environments:
- System configurations (`hosts/maverick/configuration.nix`, `darwin/iceman/configuration.nix`) install only essential, language-agnostic tooling (git, editors, CLI utilities).
- Feature modules provide shared developer tooling (zsh, ghostty, tmux, fzf, ripgrep, etc.).
- Individual projects define their toolchains in `shell.nix`/flake files. Example:

```nix
{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  buildInputs = with pkgs; [
    python311
    python311Packages.pip
    nodejs_20
  ];
  shellHook = ''
    export PROJECT_ROOT=$(pwd)
  '';
}
```

- Developers enter environments with `nix-shell` or `nix develop`; optional `direnv` integration can streamline activation later.
- The repository justfile provides helper recipes (`dev-shell`, `dev`) for contributing to this configuration.

## Consequences
**Positive**
- Clean separation between system tooling and project dependencies.
- No version conflicts—each project controls its own toolchain.
- Reproducible environments that work on both NixOS and macOS.
- Explicit documentation of project requirements.
- System remains lightweight and easier to maintain.

**Negative**
- Each project must maintain a Nix shell definition.
- First-time environment entry can take longer while dependencies build/download.
- Contributors must understand basic Nix concepts.
- Some tools might require custom packaging if absent from nixpkgs.

**Neutral**
- Disk usage increases because dependencies are per-project.
- direnv integration is a future enhancement, not yet implemented.
- Language servers may still warrant global installs depending on editor needs.
