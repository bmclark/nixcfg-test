# NixCfg Implementation Plan

Cross-platform NixOS + nix-darwin unified configuration for two systems:
- **carbon** -- NixOS laptop (x86_64-linux)
- **macmini** -- Mac Mini (aarch64-darwin)

## Overview

13 phases transforming a minimal Nix configuration into a fully-featured, Dracula-themed, cross-platform development environment. All managed declaratively through Nix flakes, home-manager, and nix-darwin.

Primary goal: make the day-to-day experience as consistent as practical across NixOS, macOS, and future hosts, especially for programs, keybindings, terminal workflows, and core user-facing behavior.

---

## Implementation Batches

```
Batch 1 (parallel, new files):   Phase 1 (git) + Phase 4 (tmux) + Phase 5 (atuin)
Batch 2 (parallel):              Phase 2+3 (zsh+starship) + Phase 6 (ghostty+fonts)
Batch 3 (parallel):              Phase 7 (vscode) + Phase 8 (browsers)
Batch 4 (sequential):            Phase 9 (homebrew cleanup)
Batch 5 (parallel):              Phase 12 (theme system) + Phase 13 (hyprland rice)
Batch 6 (sequential):            Phase 10 (keyboard audit)
Batch 7 (final):                 Phase 11 (documentation + ADRs)
```

---

## Phase 1: Git Configuration

| Action | File |
|--------|------|
| Create | `home/features/development/git.nix` |
| Modify | `home/features/development/default.nix` |
| Modify | `home/bclark/carbon.nix`, `home/bclark/macmini.nix` |

- `programs.git`: identity, defaultBranch = "main", push.autoSetupRemote, pull.rebase
- `programs.git.delta`: Dracula syntax-theme, line-numbers, side-by-side
- Aliases: st, co, br, ci, lg, unstage, last, amend
- Ignores: .DS_Store, .direnv/, result, result-*

---

## Phase 2: Zsh Enhancement

| Action | File |
|--------|------|
| Modify | `home/features/cli/zsh.nix` |
| Modify | `home/features/cli/default.nix` |

- **Plugins:** syntaxHighlighting, autosuggestion (Dracula comment color), historySubstringSearch
- **Extra plugins:** nix-zsh-completions, zsh-you-should-use, zsh-autopair, zsh-nix-shell
- **Emacs keybindings:** explicit `bindkey -e`
- **History:** 100k entries, ignoreAllDups, ignoreSpace, extended, share
- **Aliases:** navigation (..), files (ls→eza, cat→bat), git shortcuts, nix helpers, utilities
- **initContent:** env vars, colored man pages (Dracula), extract(), Hyprland autostart (Linux)
- **programs.direnv:** with nix-direnv for fast dev shells
- **programs.nix-index:** file database for nixpkgs
- **programs.dircolors:** Dracula-themed ls colors
- **programs.bat:** explicit Dracula theme
- **New packages:** dust, prettyping, unzip

---

## Phase 3: Starship P10k-Style Prompt

| Action | File |
|--------|------|
| Modify | `home/features/cli/zsh.nix` |

- 2-line powerline format with Dracula palette
- Line 1: user@host, directory, git status, cmd duration, right-aligned context (nix/python/node)
- Line 2: `❯` (green) or `❯` (red on error)
- Powerline arrow separators
- Transient prompt via manual zle-line-init (home-manager's enableTransience is Fish-only)

---

## Phase 4: Tmux Module

| Action | File |
|--------|------|
| Create | `home/features/cli/tmux.nix` |
| Modify | `home/features/cli/default.nix` |
| Modify | `home/bclark/carbon.nix`, `home/bclark/macmini.nix` |

- Prefix: Ctrl+A, mouse enabled, 100k history, base index 1
- keyMode: vi (copy-mode only; shell stays emacs via bindkey -e)
- Plugins: sensible, dracula, yank, pain-control, logging
- Splits: `|` horizontal, `-` vertical
- Logging: compensates for Ghostty's lack of auto-logging (GitHub #5209)

---

## Phase 5: Atuin Shell History

| Action | File |
|--------|------|
| Create | `home/features/cli/atuin.nix` |
| Modify | `home/features/cli/default.nix` |
| Modify | `home/bclark/carbon.nix`, `home/bclark/macmini.nix` |

- Fuzzy search, local-only (no sync), compact style, preview enabled

---

## Phase 6: Ghostty Enhancement + Fonts

| Action | File |
|--------|------|
| Modify | `home/features/cli/ghostty.nix` |
| Modify | `home/features/desktop/fonts.nix` |

**Ghostty:**
- Font: FiraCode Nerd Font, scrollback 100k, clipboard auto, dark window theme

**Fonts:**
- Add: hack-font, nerd-fonts.jetbrains-mono, nerd-fonts.symbols-only, meslo-lgs-nf
- fontconfig fallback chain: FiraCode → Hack → JetBrainsMono
- Enable fonts on macmini too

---

## Phase 7: VS Code Enhancement

| Action | File |
|--------|------|
| Modify | `home/features/development/vscode.nix` |
| Modify | `home/features/development/default.nix` |
| Modify | `flake.nix` |

- Platform-aware package (FHS on Linux, regular on Darwin)
- Full settings: Dracula theme, FiraCode font with ligatures, formatOnSave, Nix IDE with nil + alejandra
- Emacs MCX keybindings (already installed)
- Optional: nix-vscode-extensions flake input for marketplace access

---

## Phase 8: Browsers

| Action | File |
|--------|------|
| Modify | `home/features/desktop/firefox.nix` |
| Create | `home/features/desktop/chromium.nix` |
| Modify | `home/features/desktop/default.nix` |
| Modify | `home/bclark/carbon.nix`, `home/bclark/macmini.nix` |

**Firefox:** cross-platform, privacy extensions (uBlock, Privacy Badger, LocalCDN, ClearURLs, Cookie AutoDelete, Multi-Account Containers, Canvas Blocker), Dracula theme

**Chromium:** fallback browser, Bitwarden + Dracula + Dark Reader, minimal privacy flags

---

## Phase 9: Minimize Homebrew

| Action | File |
|--------|------|
| Modify | `darwin/common/homebrew.nix` |
| Modify | `home/features/cli/ghostty.nix` |

- Remove Ghostty from Homebrew casks
- Keep only Karabiner Elements (requires system-level keyboard access)

---

## Phase 10: Cross-Platform Keyboard Audit

| Action | File |
|--------|------|
| Modify | `docs/keyboard-layout-strategy.md` |

- Verify full keybinding chain: physical key → Karabiner → app
- Document tmux, VS Code, and edge cases (Cmd+Q → Ctrl+Q doesn't quit)
- Ensure identical shortcuts between NixOS and macOS

---

## Phase 11: Documentation & ADRs

| Action | File |
|--------|------|
| Create | ADR-008 through ADR-012 |
| Create | README.md per feature directory |
| Modify | README.md, docs/dotfiles-migration.md, docs/adr/README.md |
| Modify | ADR-002 |

---

## Phase 12: Switchable Theme System

| Action | File |
|--------|------|
| Create | `home/themes/tokyo-night.nix`, `home/themes/synthwave84.nix` |
| Modify | `flake.nix`, `justfile` |

- All palette files export identical attribute names
- Theme passed via specialArgs from flake.nix
- `just theme tokyo-night` rebuilds everything with new colors
- Switches: Ghostty, Starship, Hyprland, Waybar, Wofi, Dunst, fzf, VS Code, Tmux, GTK, Emacs

---

## Phase 13: Hyprland Full Rice

| Action | File |
|--------|------|
| Modify | `home/features/desktop/hyprland.nix` |
| Modify | `home/features/desktop/wayland.nix` |

- Layerrules: blur on waybar/wofi/gtk-layer-shell
- Window rules: float dialogs, PiP, workspace assignments, opacity overrides
- Plugin: hyprexpo (workspace overview)
- Tune: gaps, opacity, gestures
- Theme-aware wallpaper

---

## File Inventory

### New files (15)

| File | Purpose |
|------|---------|
| `home/features/development/git.nix` | Git with delta, aliases, identity |
| `home/features/cli/tmux.nix` | Tmux with Dracula, logging |
| `home/features/cli/atuin.nix` | Atuin fuzzy history |
| `home/features/desktop/chromium.nix` | Chromium fallback browser |
| `home/themes/tokyo-night.nix` | Tokyo Night palette |
| `home/themes/synthwave84.nix` | SynthWave '84 palette |
| `docs/adr/ADR-008-tmux-integration.md` | Tmux ADR |
| `docs/adr/ADR-009-browser-strategy.md` | Browser ADR |
| `docs/adr/ADR-010-shell-plugin-management.md` | Shell plugins ADR |
| `docs/adr/ADR-012-switchable-theme-system.md` | Theme system ADR |
| `home/features/cli/README.md` | CLI module docs |
| `home/features/desktop/README.md` | Desktop module docs |
| `home/features/development/README.md` | Dev module docs |
| `home/features/editors/README.md` | Editor module docs |
| `home/themes/README.md` | Theme system docs |

### Modified files (20)

| File | Changes |
|------|---------|
| `home/features/cli/zsh.nix` | Plugins, aliases, history, Starship, transient prompt, emacs keymap |
| `home/features/cli/default.nix` | Imports, packages, direnv/nix-index/dircolors/bat, zsh plugins |
| `home/features/cli/ghostty.nix` | Font, scrollback, clipboard |
| `home/features/development/default.nix` | Git import, nil + alejandra |
| `home/features/development/vscode.nix` | Full settings, keybindings, platform-aware |
| `home/features/desktop/firefox.nix` | Privacy extensions, cross-platform |
| `home/features/desktop/fonts.nix` | Expanded font set, fontconfig defaults |
| `home/features/desktop/default.nix` | Chromium import |
| `home/features/desktop/hyprland.nix` | Full rice |
| `home/features/desktop/wayland.nix` | Theme-aware wallpaper |
| `home/bclark/carbon.nix` | Enable new features |
| `home/bclark/macmini.nix` | Enable new features + fonts |
| `darwin/common/homebrew.nix` | Remove Ghostty, keep Karabiner only |
| `flake.nix` | Theme specialArgs, optional vscode-extensions input |
| `justfile` | Theme recipe |
| `docs/keyboard-layout-strategy.md` | Tmux/VS Code/edge cases |
| `docs/adr/ADR-002-shell-and-terminal-choices.md` | Starship is final |
| `docs/adr/README.md` | New ADR entries |
| `README.md` | Updated feature list |
| `docs/dotfiles-migration.md` | Migration status update |

---

## Verification Checklist

- [ ] `nix flake check` -- no evaluation errors
- [ ] `just switch` on NixOS (carbon)
- [ ] `just darwin-switch` on macOS (macmini)
- [ ] Ghostty: Dracula, FiraCode, 100k scrollback
- [ ] Tmux: Dracula status, Ctrl+A prefix, logging
- [ ] Prompt: 2-line powerline, git status, transient
- [ ] Emacs keys: Ctrl+A/E/K/U/W in shell
- [ ] Git: delta with Dracula syntax theme
- [ ] VS Code: Dracula, ligatures, Emacs MCX, Nix LSP
- [ ] Firefox: extensions, Dracula theme
- [ ] Chromium: Bitwarden, Dracula, Dark Reader
- [ ] Keyboard: identical shortcuts across platforms
- [ ] Atuin: fuzzy history search
- [ ] Hyprland: blur, float rules, PiP, hyprexpo
- [ ] Theme switching: `just theme tokyo-night` / `just theme dracula`
- [ ] Shell sugar: zsh-you-should-use, direnv, nix-locate
- [ ] Fonts: Hack, FiraCode, JetBrainsMono all available
- [ ] Documentation: ADRs and READMEs complete

---

## See Also

- [spec.md](spec.md) -- Detailed technical specification
- [follow-up-plans.md](follow-up-plans.md) -- Post-implementation deep-dives
- [adr/](adr/) -- Architecture Decision Records
