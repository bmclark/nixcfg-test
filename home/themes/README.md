# Theme System

Switchable color palettes for consistent theming across all tools.

## Available Themes

| Theme | File | Description |
|-------|------|-------------|
| Dracula | `dracula.nix` | Default dark theme with purple/pink accents |
| Tokyo Night | `tokyo-night.nix` | Cool blue/purple dark theme |
| SynthWave '84 | `synthwave84.nix` | Retro neon dark theme |

## Palette Structure

Every theme file exports a `palette` attrset with these attributes:

```nix
{
  palette = {
    bg = "#282a36";        # Background
    fg = "#f8f8f2";        # Foreground
    comment = "#6272a4";   # Comments, muted text
    cyan = "#8be9fd";
    green = "#50fa7b";
    orange = "#ffb86c";
    pink = "#ff79c6";
    purple = "#bd93f9";
    red = "#ff5555";
    yellow = "#f1fa8c";
    selection = "#44475a"; # Selection highlight
  };
}
```

## Switching Themes

```bash
# Switch to a different theme (rebuilds the system)
just theme tokyo-night

# Or directly via environment variable
NIXCFG_THEME=synthwave84 just switch

# Default (Dracula)
just switch
```

## How Modules Use Themes

Modules import the palette and reference colors:

```nix
let
  dracula = import ../../themes/dracula.nix;
  palette = dracula.palette;
in {
  # Use palette.purple, palette.bg, etc.
}
```

The theme is also available via `specialArgs` (`theme` and `themeName`) for modules that want to be theme-aware without hardcoding a specific import.

## Adding a New Theme

1. Create `home/themes/your-theme.nix` with the same attribute structure
2. Use `just theme your-theme` to rebuild

See [ADR-004](../../docs/adr/ADR-004-theme-standardization.md) and [ADR-012](../../docs/adr/ADR-012-switchable-theme-system.md).
