# nixcfg
_NixOS and nix-darwin configuration for managing a NixOS laptop and macOS Mac Mini with home-manager integration._

## Overview
This repository manages two systems through a single flake:
- **carbon** — NixOS laptop running Hyprland
- **macmini** — macOS Mac Mini managed with nix-darwin

Both hosts share common CLI tooling, editors, and development settings via home-manager. Dracula theming and keyboard shortcuts (Ctrl for apps, Super for window management) stay consistent across platforms.

The broader project goal is to keep the user experience as consistent as practical across NixOS, macOS, and future machines: same tools where possible, same keybindings where possible, and the same mental model for terminal, editor, and desktop workflows.

Another standing directive is that user-facing shell tooling should feel polished, not merely functional: prefer tasteful `gum`/shell-sugar enhancements and other QoL improvements when they make commands easier to understand and nicer to use.

## Features
- Dracula theme everywhere (Hyprland, Ghostty, tmux, VS Code, Emacs, Starship, waybar, wofi, dunst, fzf, bat, git delta)
- Switchable themes: Dracula, Tokyo Night, SynthWave '84 via `just theme <name>`
- CUA/Emacs-style keyboard shortcuts (Ctrl for apps, Super for WM, Emacs navigation)
- Modular feature-based architecture with per-host enable flags
- Cross-platform CLI tools (zsh, Ghostty, tmux, atuin, fzf, ripgrep, etc.)
- Zsh with native plugins (syntax highlighting, autosuggestions, nix completions)
- Starship prompt (P10k-style 2-line powerline with transient prompt)
- Tmux with Dracula status bar, session logging (compensates for Ghostty lacking auto-logging)
- Atuin fuzzy shell history search
- Git with delta (side-by-side diffs, Dracula syntax theme)
- VS Code with Dracula, Emacs MCX keybindings, Nix LSP (nil + alejandra)
- Vanilla Emacs with Dracula theme (runs as systemd daemon, use `emacsclient`)
- Firefox (privacy-focused, 10+ extensions) + Chromium (fallback)
- Hyprland window manager with full rice (blur, shadows, animations, window rules, hyprexpo)
- Complete Wayland ecosystem (waybar, wofi, dunst, hyprpaper, hypridle, wlsunset)
- PipeWire audio with PulseAudio compatibility
- Bluetooth support with battery reporting and Blueman GUI
- Desktop niceties (automounting, polkit, file manager)
- Karabiner-Elements for macOS keyboard remapping (Cmd→Ctrl)
- Just-based build automation with theme switching
- Per-project development environments (nix-shell / nix develop)
- direnv + nix-direnv for automatic dev shell loading
- Plymouth boot splash with manufacturer logo
- Firewall (SSH-only inbound)
- Agenix secrets management (age-encrypted, decrypted at activation)
- CVE monitoring via vulnix
- Weekly automatic flake update (systemd timer)
- CI via GitHub Actions (`nix flake check` on push/PR)
- Night light (wlsunset, location-based)

## Quick Start
1. **Prerequisites**
   - NixOS or macOS with Nix installed
   - Git
   - Just (`nix-shell -p just`)
2. **Clone the repository**
   ```bash
   git clone <repository-url> ~/nixcfg
   cd ~/nixcfg
   ```
3. **Review and customize**
   - Toggle features in `home/bclark/carbon.nix` or `home/bclark/macmini.nix`
   - Adjust system settings in `hosts/carbon/configuration.nix` or `darwin/macmini/configuration.nix`
   - Update user details in `home/bclark/home.nix`
4. **Build and switch**
   - Current machine: `just switch`
   - NixOS only: `just nixos-switch`
   - macOS only: `just darwin-switch`
5. **Test before applying (optional)**
   - Current machine: `just test`
   - NixOS only: `just nixos-test`
   - macOS only: `just darwin-test`

## Common Commands
| Command | Description |
|---------|-------------|
| `just --list` | Show all available commands |
| `just switch` | Platform-aware rebuild and switch |
| `just test` | Platform-aware test |
| `just update` | Update all flake inputs |
| `just update-all` | Update, build, and switch |
| `just theme <name>` | Switch theme (dracula, tokyo-night, synthwave84) |
| `just gc` | Garbage collect (7 days) |
| `just clean` | Garbage collect and optimize |
| `just check` | Validate flake |
| `just build-current` | Build the current machine without switching |
| `just nixos-switch` | Rebuild the current NixOS host |
| `just darwin-switch` | Rebuild the current macOS host |
| `just home-switch` | Rebuild home-manager for the current host |
| `just home-build` | Build home-manager for the current host |
| `just show-json` | Show flake outputs as JSON |
| `just check-trace` | Run `nix flake check --show-trace` |

See the [justfile](justfile) for the full catalog.

## Repository Structure
```
nixcfg/
├── flake.nix              # Main flake configuration
├── justfile               # Build automation commands
├── .github/workflows/     # CI (nix flake check on push/PR)
├── secrets/               # agenix-encrypted secrets
│   └── secrets.nix        # Secret definitions and public keys
├── hosts/                 # NixOS system configurations
│   ├── carbon/            # NixOS laptop (firewall, plymouth, TLP, etc.)
│   └── common/            # Shared NixOS settings
├── darwin/                # macOS system configurations
│   ├── macmini/           # macOS Mac Mini
│   └── common/            # Shared macOS settings (Homebrew)
├── home/                  # Home-manager configurations
│   ├── bclark/            # User-specific configs (per-host feature flags)
│   ├── features/          # Modular feature configurations
│   │   ├── cli/           # Shell, terminal, tmux, atuin, fzf
│   │   ├── desktop/       # Hyprland, wayland, browsers, fonts, karabiner
│   │   ├── development/   # Git, VS Code, dev packages
│   │   └── editors/       # Emacs (daemon mode)
│   ├── common/            # Shared home-manager settings
│   └── themes/            # Color palettes (Dracula, Tokyo Night, SynthWave '84)
└── docs/                  # Documentation
    ├── adr/               # Architecture Decision Records
    ├── keyboard-layout-strategy.md
    └── dotfiles-migration.md
```

## Enabling Features
Features reside in `home/features/` and are toggled per host configuration:

```nix
features = {
  cli = {
    zsh.enable = true;
    ghostty.enable = true;
    fzf.enable = true;
    tmux.enable = true;
    atuin.enable = true;
  };
  editors = {
    emacs.enable = true;
  };
  desktop = {
    hyprland.enable = true;  # NixOS only
    wayland.enable = true;   # NixOS only
    firefox.enable = true;
    chromium.enable = true;
    fonts.enable = true;
    karabiner.enable = true; # macOS only
  };
  development = {
    git.enable = true;
    vscode.enable = true;
  };
};
```

Explore `home/features/` to see all modules. Each feature directory has a README.

## Hyprland Configuration (NixOS)
The carbon laptop runs Hyprland with a carefully tuned configuration:
- **Aesthetics**: Glass blur effects, soft shadows, smooth animations with custom bezier curves
- **Window rules**: Dialogs float, PiP pins, browsers get full opacity, workspace assignments
- **Keyboard**: CUA/Emacs-style bindings (Ctrl+W to close, Alt+Tab to switch, Ctrl+Alt+B/F/P/N for navigation)
- **Plugins**: hyprexpo for workspace overview (Super+Tab)
- **Audio**: PipeWire with PulseAudio compatibility, WirePlumber session management, waybar integration
- **Bluetooth**: BlueZ with battery reporting, Blueman GUI, waybar bluetooth module
- **Services**: hyprpaper (wallpapers), hypridle (idle management), wofi (launcher), dunst (notifications)
- **Desktop**: Automatic USB mounting (udiskie), polkit authentication, thunar file manager
- **Status bar**: Waybar with workspaces, window title, clock, weather, network, audio, bluetooth, battery, system tray
- **Theme**: Dracula colors throughout (borders, shadows, waybar, dunst, wofi)

See the [Hyprland Configuration Guide](docs/hyprland-configuration.md) for keyboard shortcuts, audio/Bluetooth setup, customization options, and troubleshooting.

## Adding a New Host
1. Create `hosts/<hostname>/` (NixOS) or `darwin/<hostname>/`.
2. Add `default.nix` and `configuration.nix` following existing examples.
3. Create `home/bclark/<hostname>.nix` for the user configuration.
4. Register the host in `flake.nix` under `nixosConfigurations` or `darwinConfigurations`.
5. Extend the `justfile` with new host-specific commands if needed.

## Documentation
- [System User Guide](docs/system-user-guide.md)
- [Architecture Decision Records](docs/adr/) (ADR-001 through ADR-013)
- [Keyboard Shortcut Conflicts](docs/keyboard-shortcut-conflicts.md)
- [Hyprland Configuration Guide](docs/hyprland-configuration.md)
- [Keyboard Layout Strategy](docs/keyboard-layout-strategy.md)
- [Dotfiles Migration Status](docs/dotfiles-migration.md)
- Feature READMEs: [CLI](home/features/cli/README.md) | [Desktop](home/features/desktop/README.md) | [Development](home/features/development/README.md) | [Editors](home/features/editors/README.md) | [Themes](home/themes/README.md)

## Development
- Development tooling is project-scoped using `nix-shell`/`nix develop` (see [ADR-005](docs/adr/ADR-005-development-environment-approach.md)).
- Use `just dev` or `just dev-shell` for the nixcfg development environment.
- Build automation and workflows are described in [ADR-006](docs/adr/ADR-006-build-automation-with-justfile.md).

## Secrets Management (agenix)

Secrets are encrypted with age and decrypted at system activation time. They never appear in the Nix store in plaintext.

```bash
# Add your SSH public key to secrets/secrets.nix, then:
cd secrets
agenix -e wifi-passwords.age    # Encrypt a new secret
agenix -e api-tokens.age        # Encrypt another secret

# Reference in NixOS config:
# age.secrets.wifi-passwords.file = ../secrets/wifi-passwords.age;
```

See `secrets/secrets.nix` for the full setup.

## Maintenance
- Update dependencies: `just update`
- Automatic updates: flake inputs update weekly (Sunday 09:00 via systemd timer)
- Garbage collection: `just gc` (7 days) or `just gc-old` (30 days)
- Optimize store: `just optimize`
- Clean everything: `just clean`
- Validate configuration: `just check`
- CVE scan: `vulnix --system` (scan installed packages for known vulnerabilities)

## Troubleshooting
- **Build fails with "attribute 'X' missing"**
  Run `just update` to refresh inputs and verify the attribute exists in nixpkgs.
- **Karabiner not working on macOS**
  Grant Accessibility and Input Monitoring permissions, then restart with
  `launchctl kickstart -k gui/$(id -u)/org.pqrs.karabiner.karabiner_console_user_server`.
- **Hyprland not starting**
  Check logs via `journalctl -u display-manager` and confirm Hyprland is enabled in `hosts/carbon/configuration.nix`.
- **Hyprland services not starting**
  Ensure systemd integration is enabled. Check service status with `systemctl --user status hypridle` or `systemctl --user status hyprpaper`. See the [Hyprland Configuration Guide](docs/hyprland-configuration.md) for detailed troubleshooting.
- **Audio not working**
  Verify PipeWire services are running: `systemctl --user status pipewire pipewire-pulse wireplumber`. Check audio devices with `wpctl status`.
- **Bluetooth not connecting**
  Verify bluetooth service: `systemctl status bluetooth`. Check rfkill: `rfkill list`. Use `bluetoothctl` or Blueman GUI for pairing.
- **USB drives not automounting**
  Verify udisks2 and udiskie services are running. Ensure polkit agent is active.
- **Home-manager changes not applying**
  Because home-manager is integrated, use `just switch` rather than raw `home-manager switch` for normal rebuilds. For rapid iteration, run `just home-switch`.
- **Theme not changing**
  Ensure you use the environment variable: `NIXCFG_THEME=tokyo-night just switch` or `just theme tokyo-night`.

## License
This project is licensed under the MIT License.

## Acknowledgments
- Original structure inspired by [m3tamere/nixcfg](https://code.m3ta.dev/m3tam3re/nixcfg)
- Additional ideas borrowed from [Misterio77's nix-config](https://github.com/Misterio77/nix-config)
- Dracula theme by the [Dracula Theme](https://draculatheme.com/) community

## Contributing
This is a personal configuration repository, but feel free to reuse ideas. Review the [Architecture Decision Records](docs/adr/) to understand the design principles before making significant changes.
