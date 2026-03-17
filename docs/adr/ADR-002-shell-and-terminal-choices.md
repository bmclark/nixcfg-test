# ADR-002: Shell and Terminal Choices

**Status**: Accepted
**Date**: 2025-01-13 (updated 2026-03-14)

## Context
The configuration needs a shell and terminal emulator that:
- Works seamlessly on both NixOS and macOS
- Offers modern conveniences (completion, history search, syntax highlighting)
- Integrates with development workflows and tooling
- Supports Dracula theming
- Benefits from active maintenance and community support

The previous setup used Fish + Kitty. Existing personal dotfiles already rely on zsh with Antigen and Powerlevel10k, so the system should align with that direction.

## Decision
**Shell: zsh**
- Default shell on both platforms (`programs.zsh.enable = true` in shared system modules).
- User-level configuration handled in `home/features/cli/zsh.nix` behind `features.cli.zsh.enable`.
- **Starship prompt** configured for P10k-style 2-line powerline with Dracula palette. This is the final prompt solution (not temporary).
- Plugins managed natively via home-manager (see [ADR-010](ADR-010-shell-plugin-management.md)): syntax highlighting, autosuggestions, history substring search.
- Integrations for tools like zoxide, eza, fzf, atuin, and direnv are enabled via zsh hooks.
- Comprehensive aliases for navigation, git, nix, and modern CLI replacements.
- Emacs keybindings explicit via `bindkey -e` (tmux copy-mode also stays emacs-style).
- Hyprland auto-starts on tty1 for the NixOS host.
- Transient prompt via manual `zle-line-init` (home-manager's `enableTransience` is Fish-only).

**Terminal: Ghostty**
- Chosen as the terminal emulator for both platforms.
- Linux installs via nixpkgs; macOS uses manual install (Homebrew cask removed).
- Configuration delivered via `home/features/cli/ghostty.nix`, writing XDG config or home-managed files as appropriate.
- Applies Dracula theme, FiraCode Nerd Font, block cursor, zsh integration, 100k scrollback, clipboard integration.
- No auto-logging support -- compensated by tmux-logging plugin (see [ADR-008](ADR-008-tmux-integration.md)).

## Consequences
**Positive**
- zsh offers portability, POSIX compatibility, and widespread ecosystem support.
- Starship delivers a polished P10k-style prompt with full Dracula theming -- no migration needed.
- Ghostty provides a consistent, GPU-accelerated experience across Linux and macOS.
- CLI tool integrations (zoxide, fzf, eza, atuin, direnv) behave uniformly on every host.
- Shared terminal setup strengthens muscle memory and reduces per-platform drift.
- No runtime plugin manager (Antigen eliminated) -- fully declarative via home-manager.

**Negative**
- zsh demands more manual configuration compared to Fish's batteries-included approach.
- Ghostty is newer than incumbents like Alacritty/Kitty, so long-term stability must be monitored.

**Neutral**
- Users moving from Fish or other terminals face a learning curve.
- Ghostty configuration may evolve as upstream adds features (e.g., native logging).
