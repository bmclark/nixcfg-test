# ADR-010: Shell Plugin Management

**Status**: Accepted
**Date**: 2026-03-14

## Context

The previous dotfiles setup used Antigen with 23+ zsh plugins, requiring a runtime plugin manager. The Nix configuration needs a declarative approach that:
- Eliminates runtime plugin managers (Antigen, zplug, etc.)
- Provides reproducible plugin installations across systems
- Integrates naturally with home-manager's zsh module
- Supports syntax highlighting, autosuggestions, and completion

## Decision

**Home-manager native zsh plugins** with no external plugin manager.

### Built-in modules (home-manager `programs.zsh.*`)
- `syntaxHighlighting.enable`: real-time syntax highlighting with main, brackets, pattern, cursor highlighters
- `autosuggestion.enable`: fish-like autosuggestions from history + completion
- `historySubstringSearch.enable`: arrow key history substring search

### Package-based plugins (installed via `home.packages`)
- `nix-zsh-completions`: tab completion for nix, nixos-rebuild, nix-env
- `zsh-you-should-use`: reminds of existing aliases when typing full commands
- `zsh-nix-shell`: proper zsh in nix-shell environments (instead of bash fallback)

### Supporting programs (home-manager `programs.*`)
- `programs.direnv` + `nix-direnv`: automatic dev shell loading in project directories
- `programs.nix-index`: `nix-locate` for finding which package provides a binary
- `programs.dircolors`: themed `ls` colors
- `programs.bat`: syntax-highlighted cat with Dracula theme
- `programs.zoxide`: smart cd with frecency
- `programs.eza`: modern ls with icons and git integration
- `programs.fzf`: fuzzy finder with zsh integration
- `programs.atuin`: fuzzy shell history search

### Prompt
- Starship configured for P10k-style 2-line powerline (see zsh.nix)
- Transient prompt via manual `zle-line-init` (home-manager's `enableTransience` is Fish-only)

## Consequences

**Positive**
- Fully declarative: no runtime plugin manager, no `antigen update` commands
- Reproducible across systems (same plugins on NixOS and macOS)
- Faster shell startup (no plugin manager overhead)
- Plugin versions pinned by nixpkgs (consistent, auditable)

**Negative**
- Adding new plugins requires a nix rebuild (not instant like `antigen bundle`)
- Some obscure zsh plugins may not be in nixpkgs
- No lazy-loading support (all plugins load at startup)

**Neutral**
- Migration from Antigen requires mapping old plugin list to home-manager equivalents
- Shell startup time should be measured after migration to ensure no regression

### oh-my-zsh tmux plugin equivalents

The upstream `.dotfiles` used the oh-my-zsh `tmux` plugin via Antigen, which provided shorthand aliases (`ts`, `ta`, `tad`, `tkss`, `tl`). Rather than pulling in the full OMZ plugin, these are declared as plain shell aliases in `zsh.nix`, keeping the no-plugin-manager approach intact.
