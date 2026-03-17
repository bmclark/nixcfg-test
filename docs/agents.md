# AI Agent Bootstrap Guide for `nixcfg`

This file is the intended starting point for any new AI agent session in this repository.

If the user opens a fresh context window, they should be able to include this file plus their request, and the agent should then know:

- what this repository does
- where the source of truth lives
- which files to load for a given task
- how to trace imports and feature flags
- how to validate changes safely

Do not assume prior context beyond this file.

---

## Mission and Repository Shape

This repository manages one NixOS host and one macOS host from a single flake:

- `maverick`: NixOS laptop
- `iceman`: macOS machine managed with `nix-darwin`

Most user-facing configuration is implemented as modular home-manager features under `home/features/`, then enabled per host in `home/bclark/maverick.nix` or `home/bclark/iceman.nix`.

When adding or changing user-facing shell commands, CLI workflows, or terminal dashboards, prefer polished UX by default: use `gum` and similar shell sugar when it meaningfully improves readability, discoverability, QoL, and ease of use.

Top-level areas:

- `flake.nix`: main entrypoint, outputs, host registration, theme injection, templates
- `justfile`: operational commands for build, switch, test, update
- `hosts/`: NixOS system configuration
- `darwin/`: macOS system configuration
- `home/`: home-manager modules, host user configs, themes, shared user config
- `secrets/`: agenix secrets metadata
- `templates/`: project templates exported by the flake
- `docs/`: design docs, plans, ADRs, and this file

---

## What To Read First

For a new task, load files in this order until you have enough context:

1. `docs/agents.md` (this file)
2. `docs/README.md`
3. `flake.nix`
4. `justfile`
5. The host config affected by the task:
   - `home/bclark/maverick.nix`
   - `home/bclark/iceman.nix`
   - `hosts/maverick/configuration.nix`
   - `darwin/iceman/configuration.nix`
6. The relevant feature module or system module
7. Any ADR or doc specifically covering the area you are changing

Read `docs/plan.md` and `docs/spec.md` when the task touches architecture, unfinished roadmap work, or you need the original intended module pattern.

---

## How To Find The Right Files

Use this procedure instead of guessing.

### If the task changes user tools or app behavior

Start here:

- `home/bclark/maverick.nix`
- `home/bclark/iceman.nix`
- `home/features/<category>/default.nix`
- `home/features/<category>/<feature>.nix`

Interpretation:

- host files tell you whether a feature is enabled
- feature hub `default.nix` files tell you which modules are imported
- feature module files hold the actual implementation

### If the task changes system behavior

Start here:

- NixOS: `hosts/maverick/default.nix`, `hosts/maverick/configuration.nix`, `hosts/common/default.nix`
- macOS: `darwin/iceman/default.nix`, `darwin/iceman/configuration.nix`, `darwin/common/default.nix`
- Homebrew / Mac App Store apps: `darwin/common/homebrew.nix`

**Warning:** `homebrew.nix` has `onActivation.cleanup = "zap"` enabled. Any brew, cask, or Mac App Store app not declared in that file will be **deleted** on the next `just darwin-switch`. Always add new apps to `homebrew.nix` before switching.

### If the task changes shared user configuration

Start here:

- `home/bclark/home.nix`
- `home/common/default.nix`
- `home/bclark/dotfiles/default.nix`

### If the task changes colors, theme, or styling

Start here:

- `home/themes/<theme>.nix`
- the consuming module under `home/features/...`
- `flake.nix` for `themeName` / theme injection

### If the task changes builds, deployment, or command workflow

Start here:

- `justfile`
- `flake.nix`
- `.github/workflows/`
- relevant host module if the workflow is host-specific

### If the task changes templates or development environments

Start here:

- `templates/<name>/`
- `flake.nix` template exports
- `home/features/development/`

### If the task changes secrets

Start here:

- `secrets/secrets.nix`
- the consuming host or feature module
- any agenix references in `hosts/` or `darwin/`

---

## Import Tracing Rules

When you need more context, trace imports in this order:

1. `flake.nix`
2. host `default.nix`
3. host `configuration.nix`
4. shared `default.nix` for that platform
5. user host file in `home/bclark/`
6. `home/features/<category>/default.nix`
7. concrete feature module

Practical examples:

- A shell task usually flows through `home/bclark/<host>.nix` -> `home/features/cli/default.nix` -> `home/features/cli/zsh.nix`
- A Hyprland task usually flows through `hosts/maverick/default.nix` and `home/bclark/maverick.nix` -> `home/features/desktop/default.nix` -> `home/features/desktop/hyprland.nix` and `home/features/desktop/wayland.nix`
- A macOS keyboard task usually flows through `darwin/iceman/configuration.nix` and `home/bclark/iceman.nix` -> `home/features/desktop/karabiner.nix`

Do not load the whole repository by default. Load the minimum set that explains the path from flake -> host -> feature -> concrete implementation.

---

## Task-To-File Map

Use this as the first lookup table.

| Task area | Files to read first |
| --- | --- |
| Shell / zsh / aliases / prompt | `home/features/cli/zsh.nix`, `home/features/cli/default.nix`, host file in `home/bclark/` |
| Fish shell | `home/features/cli/fish.nix`, `home/features/cli/default.nix`, host file |
| Ghostty terminal | `home/features/cli/ghostty.nix`, host file |
| Tmux | `home/features/cli/tmux.nix`, `docs/adr/ADR-008-tmux-integration.md` |
| Atuin / fzf / CLI utilities | `home/features/cli/atuin.nix`, `home/features/cli/fzf.nix`, `home/features/cli/default.nix` |
| Git | `home/features/development/git.nix`, host file |
| VS Code | `home/features/development/vscode.nix`, host file |
| Emacs | `home/features/editors/emacs.nix`, `home/features/editors/default.nix` |
| Firefox | `home/features/desktop/firefox.nix`, host file |
| Chromium | `home/features/desktop/chromium.nix`, host file |
| Hyprland | `home/features/desktop/hyprland.nix`, `home/features/desktop/wayland.nix`, `docs/hyprland-configuration.md`, `home/bclark/maverick.nix`, `hosts/maverick/configuration.nix` |
| Fonts | `home/features/desktop/fonts.nix`, `home/themes/README.md` |
| Karabiner | `home/features/desktop/karabiner.nix`, `darwin/iceman/configuration.nix`, `home/bclark/iceman.nix` |
| Themes | `home/themes/*.nix`, `flake.nix`, consuming modules |
| NixOS host behavior | `hosts/maverick/configuration.nix`, `hosts/maverick/default.nix`, `hosts/common/default.nix` |
| macOS host behavior | `darwin/iceman/configuration.nix`, `darwin/iceman/default.nix`, `darwin/common/default.nix` |
| Homebrew / Mac App Store apps | `darwin/common/homebrew.nix` |
| Build / switch / test commands | `justfile`, `flake.nix` |
| Secrets / agenix | `secrets/secrets.nix`, host config, consuming module |
| Project templates | `templates/<name>/`, `flake.nix` |
| Architecture rationale | `docs/adr/`, `docs/spec.md`, `docs/plan.md` |

---

## Source Of Truth By Concern

When documents and code disagree, prefer these sources:

| Concern | Source of truth |
| --- | --- |
| Actual host outputs and wiring | `flake.nix` |
| Operational commands | `justfile` |
| NixOS system behavior | `hosts/` |
| macOS system behavior | `darwin/` |
| User environment and apps | `home/` |
| Enabled features per host | `home/bclark/maverick.nix`, `home/bclark/iceman.nix` |
| Theme palette values | `home/themes/*.nix` |
| Design rationale | `docs/adr/` |
| Planned but not necessarily implemented work | `docs/plan.md` |
| Intended patterns and examples | `docs/spec.md` |

Important: `docs/plan.md` and `docs/spec.md` may describe goals or patterns that are only partially implemented. Verify against live code before changing anything.

---

## Actual Commands In This Repo

Use the command names that really exist in `justfile`:

```bash
just switch
just test
just check
just build-current
just nixos-switch
just darwin-switch
just home-switch
just home-build
just update
just build-all
just show-json
just check-trace
just theme dracula
just theme tokyo-night
```

Validation defaults:

1. After editing Nix files, run `just check`
2. If only home-manager changed, run `just home-switch`
3. If system-level NixOS changed, run `just nixos-switch` or `just nixos-test`
4. If system-level macOS changed, run `just darwin-switch` or `just darwin-test`

Most day-to-day recipes infer the current machine automatically. Use explicit `*-host` recipes only for bootstrap, remote, or cross-host work.

If you cannot execute a full rebuild, at minimum run `just check` and state what you could not verify.

---

## Nix Module Conventions

Most feature modules follow this pattern:

```nix
{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.features.<category>.<name>;
in {
  options.features.<category>.<name>.enable =
    mkEnableOption "enable <description>";

  config = mkIf cfg.enable {
    # implementation
  };
}
```

Common conventions:

- feature modules live in `home/features/<category>/`
- feature hub files are `home/features/<category>/default.nix`
- features are enabled explicitly in `home/bclark/maverick.nix` or `home/bclark/iceman.nix`
- cross-platform logic uses `pkgs.stdenv.isLinux` and `pkgs.stdenv.isDarwin`
- theme-aware modules should use palette attributes from `home/themes/*.nix`, not hardcoded colors

---

## Current Host Model

### `maverick`

- NixOS
- x86_64-linux
- Hyprland / Wayland desktop
- system config under `hosts/maverick/`
- user config under `home/bclark/maverick.nix`

### `iceman`

- macOS via `nix-darwin`
- aarch64-darwin
- no Hyprland
- system config under `darwin/iceman/`
- user config under `home/bclark/iceman.nix`

Shared user experience is implemented mostly through home-manager features.

---

## Architecture and Design Docs Worth Loading

Load only the relevant documents.

- `docs/README.md`: high-level repo map
- `docs/spec.md`: intended module pattern and implementation details
- `docs/plan.md`: roadmap and incomplete work
- `docs/hyprland-configuration.md`: Hyprland operational details
- `docs/system-user-guide.md`: user-facing behavior overview
- `docs/adr/ADR-001-architecture-and-modularization.md`: repo structure rationale
- `docs/adr/ADR-006-build-automation-with-justfile.md`: command workflow
- `docs/adr/ADR-007-hyprland-configuration-modernization.md`: Hyprland rationale
- `docs/adr/ADR-008-tmux-integration.md`: tmux decisions
- `docs/adr/ADR-009-browser-strategy.md`: browser decisions
- `docs/adr/ADR-010-shell-plugin-management.md`: shell strategy
- `docs/adr/ADR-012-switchable-theme-system.md`: theme switching design
- `docs/adr/ADR-013-documentation-maintenance-for-user-guides.md`: docs maintenance expectations
- `docs/adr/ADR-014-macos-platform-parity.md`: macOS platform parity decisions and Homebrew strategy

---

## Common Pitfalls

Check these before changing code:

1. Do not invent `just` command names. Verify against `justfile`.
2. Do not assume docs are fully current. Confirm behavior in live code.
3. Do not hardcode colors when a theme palette attribute should be used.
4. Do not add a feature module without also checking the category `default.nix` import list and the host enable flags.
5. Do not change a host-specific behavior without checking whether the other host needs a guard.
6. Do not assume package names or option paths. Verify against the available Nix tooling or authoritative docs.
7. `Ghostty` does not provide the logging workflow used here; tmux handles session logging instead.
8. Linux VS Code and macOS VS Code differ; platform guards matter.
9. Some docs describe aspirational structure. `flake.nix` and the concrete module files are authoritative.
10. Use the actual current date in docs or ADR updates, not a guessed date.
11. `pkgs.chromium` is not available on aarch64-darwin. The chromium module is guarded with `pkgs.stdenv.isLinux`. macOS uses Google Chrome via Homebrew cask.
12. Emacs daemon uses `services.emacs` (systemd) on Linux and `launchd.agents.emacs` on macOS — do not use `services.emacs` without a Linux guard.
13. Clipboard functions in zsh use `wl-copy` on Linux and `pbcopy` on macOS — use Nix interpolation for platform selection.
14. Any new Homebrew cask, formula, or MAS app must be added to `darwin/common/homebrew.nix` before `darwin-switch` or `zap` will remove it.

---

## If The User Asks To Add Something

Use this checklist:

1. Identify whether the change belongs in `hosts/`, `darwin/`, `home/features/`, `home/common/`, `home/bclark/`, `templates/`, or `docs/`
2. Read the host file that enables the relevant area
3. Read the feature hub `default.nix` for that category
4. Read the concrete module that already implements the closest similar behavior
5. Check whether the change is platform-specific
6. Check whether theme or shared palette usage is required
7. Update imports or enable flags if adding a new module
8. Run `just check`
9. Run the smallest appropriate rebuild/test command if feasible

---

## Optional External Tools

If the agent environment exposes the repo's MCP servers, use them when appropriate:

- `nixos`: search package names and home-manager/NixOS options before writing Nix code
- `hyprland`: inspect or test live Hyprland state when working on desktop behavior

If those tools are not available in the current environment, continue using the repository code and local validation commands.

---

## Minimal Context Recipes

These are good default context bundles for a fresh session.

### Add or change a CLI tool

Load:

- `docs/agents.md`
- `flake.nix`
- `justfile`
- `home/bclark/<target-host>.nix`
- `home/features/cli/default.nix`
- closest matching file in `home/features/cli/`

### Add or change a desktop app

Load:

- `docs/agents.md`
- `home/bclark/<target-host>.nix`
- `home/features/desktop/default.nix`
- target module in `home/features/desktop/`
- host system file if platform-specific

### Add or change system behavior

Load:

- `docs/agents.md`
- `flake.nix`
- `justfile`
- relevant host files in `hosts/` or `darwin/`
- relevant shared platform file

### Add a new feature module

Load:

- `docs/agents.md`
- `docs/spec.md`
- `home/features/<category>/default.nix`
- one existing sibling module in the same category
- target host files that should enable it

---

## Bottom Line

If you only load one file first, load `docs/agents.md`.

Then trace from:

`flake.nix` -> host file -> category `default.nix` -> concrete module -> relevant ADR/doc

That path is the fastest reliable way to gather enough context without overloading the session.
