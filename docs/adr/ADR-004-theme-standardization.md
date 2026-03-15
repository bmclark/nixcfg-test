# ADR-004: Theme Standardization (Dracula)

**Status**: Accepted  
**Date**: 2025-01-13

## Context
A cohesive visual identity across tools reduces cognitive load and eye strain. Requirements:
- Consistent look on both desktops (NixOS Hyprland and macOS).
- Dark theme with strong contrast for long coding sessions.
- Broad support across terminal and GUI applications.
- Straightforward to extend when adopting new tools.

## Decision
Adopt the Dracula theme everywhere and codify the official palette in `home/themes/dracula.nix`:
- Background: `#282a36`
- Foreground: `#f8f8f2`
- Comment: `#6272a4`
- Cyan: `#8be9fd`
- Green: `#50fa7b`
- Orange: `#ffb86c`
- Pink: `#ff79c6`
- Purple: `#bd93f9`
- Red: `#ff5555`
- Yellow: `#f1fa8c`

Implementation highlights:
1. **Hyprland** (`home/features/desktop/hyprland.nix`): Dracula gradients for borders, themed shadows, GTK integration.  
2. **Ghostty** (`home/features/cli/ghostty.nix`): Uses built-in Dracula theme and font settings across platforms.  
3. **fzf** (`home/features/cli/fzf.nix`): Full palette customization for prompts, cursors, and highlights.  
4. **bat** (`home/bclark/dotfiles/bat.nix`): Forces the Dracula theme for previews.  
5. **Emacs** (`home/features/editors/emacs.nix`): Loads `dracula-theme` package by default.  
6. **Starship** (`home/features/cli/zsh.nix`): Custom palette mirrors Dracula while awaiting Powerlevel10k migration.  
7. **Future editors** (e.g., VS Code) should install the Dracula Official theme during dotfiles migration.

## Consequences
**Positive**
- Uniform appearance across shells, editors, WMs, and terminals.
- Recognizable palette aids context switching between tools.
- Reduces eye strain with proven dark theme ergonomics.
- Popular theme ensures support for new tools as they are added.

**Negative**
- Users preferring light themes must reconfigure multiple touchpoints.
- Not every tool has native Dracula support; occasional manual tuning is required.
- Distinctive accent colors may not appeal to everyone.

**Neutral**
- Accessibility tweaks might require palette adjustments over time.
- Emacs and other editors may override the theme when personal dotfiles take over.
- Enforcing consistency demands diligence when adding future integrations.
