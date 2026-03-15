# ADR-012: Switchable Theme System

**Status**: Accepted
**Date**: 2026-03-14

## Context

The configuration uses Dracula theme everywhere (ADR-004), but the user wants the ability to switch between alternative themes without editing multiple files. Options considered:
- **nix-colors**: full-featured theme framework, but heavyweight for 2-3 themes
- **Custom palette files**: simple, no extra dependencies, same attribute structure

## Decision

**Custom palette files** with environment variable switching via `builtins.getEnv`.

### Theme files
Each theme exports a `palette` attrset with identical attribute names:
- `home/themes/dracula.nix` (default)
- `home/themes/tokyo-night.nix`
- `home/themes/synthwave84.nix`

Required attributes: `bg`, `fg`, `comment`, `cyan`, `green`, `orange`, `pink`, `purple`, `red`, `yellow`, `selection`.

### Wiring
- `flake.nix` reads `NIXCFG_THEME` environment variable (defaults to `"dracula"`)
- Theme is passed through `specialArgs` as `theme` and `themeName`
- Modules currently import themes directly (`import ../../themes/dracula.nix`) -- these can be gradually migrated to use the `theme` specialArg

### Switching
```bash
# Switch to Tokyo Night
just theme tokyo-night

# Switch back to Dracula (default)
just theme dracula

# Or directly:
NIXCFG_THEME=tokyo-night just switch
```

### What switches per theme (when modules use specialArgs)
- Ghostty, Starship, Hyprland borders/shadows, waybar CSS, wofi CSS, dunst notifications, fzf colors, VS Code colorTheme, tmux theme, GTK theme

## Consequences

**Positive**
- Simple implementation: no extra flake dependencies
- Single command to switch all tools to a new theme
- Easy to add new themes (copy a palette file, match attribute names)
- Gradual migration: modules can adopt `theme` specialArg incrementally

**Negative**
- Requires a full system rebuild to switch themes (not runtime)
- `builtins.getEnv` is impure (won't work with `--pure-eval`)
- Not all modules use `theme` specialArg yet (some still hardcode Dracula import)

**Neutral**
- Three themes is sufficient for the current use case
- Could be extended to support runtime switching via symlink-based approaches in the future
