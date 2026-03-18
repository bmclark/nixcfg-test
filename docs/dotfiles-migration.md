# Dotfiles Migration: Status and Approach

## Current Status

The declarative approach has been adopted. All major tools are now configured via home-manager `programs.*` modules rather than imported dotfiles. The `.dotfiles` repository (github.com/bmclark/.dotfiles) served as a reference for preferred tools, workflows, and settings.

## What Was Migrated

| Area | Approach | Module |
|------|----------|--------|
| Zsh | Declarative `programs.zsh` with native plugins | `home/features/cli/zsh.nix` |
| Git | Declarative `programs.git` with delta | `home/features/development/git.nix` |
| Tmux | Declarative `programs.tmux` with plugins | `home/features/cli/tmux.nix` |
| VS Code | Declarative `programs.vscode` with settings/keybindings | `home/features/development/vscode.nix` |
| Terminal | Ghostty (replaced Kitty) with declarative config | `home/features/cli/ghostty.nix` |
| Prompt | Starship (replaced P10k) with P10k-style config | `home/features/cli/zsh.nix` |
| Shell history | Atuin (replaced plain zsh history search) | `home/features/cli/atuin.nix` |
| Browsers | Firefox + Chromium via `programs.*` | `home/features/desktop/firefox.nix`, `chromium.nix` |
| Emacs | `programs.emacs` with Dracula theme | `home/features/editors/emacs.nix` |

## Key Decisions Made During Migration

1. **Starship over Powerlevel10k**: Starship is fully declarative via home-manager. P10k requires runtime configuration wizard and Antigen/zplug. Starship is configured to look like P10k (2-line powerline, Dracula palette).

2. **No plugin manager**: Antigen/zplug eliminated. All zsh plugins managed via home-manager native options or nixpkgs packages. See [ADR-010](adr/ADR-010-shell-plugin-management.md).

3. **Ghostty over Kitty**: Ghostty chosen for GPU acceleration, modern features, and cross-platform support. Config managed declaratively.

4. **Declarative over file imports**: All tools use `programs.*` modules rather than `home.file` imports of raw dotfiles. This provides compile-time validation and cross-platform abstractions.

## Recently Ported

- **oh-my-zsh tmux plugin aliases**: `ts`, `ta`, `tad`, `tkss`, `tl` added as shell aliases in `zsh.nix` (previously provided by the Antigen-loaded `tmux` OMZ plugin)

## Remaining from .dotfiles (Not Migrated)

- **SSH config**: Manage manually or via `programs.ssh.matchBlocks` in a future session
- **Custom scripts**: Consider adding to `home.packages` or `home.file.".local/bin/"` as needed
- **Ansible playbooks**: Out of scope for nixcfg
- **Brewfiles**: Replaced by nixpkgs and nix-darwin; only Karabiner remains in Homebrew

## Reference

- Source dotfiles: https://github.com/bmclark/.dotfiles
- Migration decisions captured in ADRs: [ADR index](adr/README.md)
