# Follow-Up Plans

Post-implementation deep-dives for the nixcfg unified configuration. Each section is a separate session focused on tuning one area after the main 13-phase plan is complete.

---

## Follow-Up A: VS Code Deep Customization

**Goal:** Maximize VS Code as a declarative, cross-platform IDE with full Nix ecosystem support.

### Extensions
- Explore `nix-vscode-extensions` overlay for marketplace extensions not in nixpkgs
- Add language-specific extensions:
  - Python: ms-python.python, ms-python.vscode-pylance
  - Rust: rust-lang.rust-analyzer
  - Go: golang.go
  - TypeScript: dbaeumer.vscode-eslint, esbenp.prettier-vscode
  - Docker: ms-azuretools.vscode-docker
  - YAML: redhat.vscode-yaml
  - Markdown: yzhang.markdown-all-in-one, davidanson.vscode-markdownlint

### Keybindings
- Fine-tune Emacs MCX keybindings (custom overrides for VS Code-specific commands)
- Resolve conflicts between Emacs MCX and VS Code defaults
- Document the full keybinding map

### Settings
- Add workspace-specific settings for Nix projects vs other languages
- Explore Claude Code / Copilot integration settings
- Add snippets and task configurations
- Profile management: consider separate VS Code profiles for different workflows

---

## Follow-Up B: Browser Hardening & Extensions

**Goal:** Harden Firefox for privacy, ensure Chromium works as a reliable fallback, sync strategy.

### Firefox Privacy
- Audit and expand privacy extensions, test for breakage on common sites
- Add `user.js` for `about:config` privacy settings (arkenfox-based)
- Key arkenfox settings to evaluate:
  - Disable WebRTC IP leak
  - Resist fingerprinting (RFP)
  - Disable telemetry
  - Harden TLS/SSL
  - Cookie isolation (first-party isolation)
- Firefox profiles: separate profiles for work vs personal

### Chromium
- Add more extensions as needed for specific sites that break in Firefox
- Evaluate Chromium-specific privacy flags (commandLineArgs)

### Cross-Browser
- Browser bookmark sync strategy (Bitwarden, xBrowserSync, or native)
- Test cross-platform browser consistency (NixOS vs macOS)
- Password manager (Bitwarden) workflow across both browsers

---

## Follow-Up C: Terminal & Shell Polish

**Goal:** Perfect the terminal experience -- prompt, multiplexer, shell functions, and completions.

### Starship Prompt
- Compare Starship output to actual P10k screenshots, adjust:
  - Segment widths and padding
  - Colors and icon choices
  - Git status format (counts vs symbols)
  - Transient prompt behavior
- If Starship doesn't suffice: add P10k as alternative prompt (non-declarative is acceptable)

### Ghostty
- Config tuning: keybinds for splits/tabs if using Ghostty without tmux
- Monitor Ghostty GitHub for auto-logging feature (#5209)
- Test Ghostty on macOS via nixpkgs vs manual install

### Tmux
- Layout presets: named sessions for common workflows
  - `dev`: editor + terminal + git log
  - `ops`: htop + logs + shell
  - `monitoring`: multiple log tails
- Tmux resurrect/continuum for session persistence across reboots
- Custom status bar segments (weather, Spotify, etc.)

### Shell
- Shell function library:
  - Project scaffolding (`mkproject`)
  - Docker helpers (`dps`, `dlog`, `dexec`)
  - Git workflow shortcuts (`pr`, `review`)
  - Nix helpers (`nix-stray` to find unreferenced store paths)
- Consider `zsh-autocomplete` for real-time type-ahead completion
- Evaluate `zoxide` as `cd` replacement (smart directory jumping)

---

## Follow-Up D: Hyprland Rice Iteration

**Goal:** Full desktop rice -- every pixel themed, smooth animations, functional beauty.

### Waybar
- Deep customization: custom modules, animations, click actions
- Custom modules: weather, media player, system tray improvements
- Hover effects and tooltips
- Module ordering and sizing optimization

### Application Launchers & Notifications
- Wofi styling: match theme precisely, custom layouts, icon support
- Dunst notification styling:
  - Action buttons
  - History popup
  - Progress bars (for volume, brightness)
  - Per-app notification rules

### Animations & Effects
- Hyprland animations: test different bezier curves, tune timings
- Find the sweet spot between smooth and responsive
- Disable animations for specific window classes (performance)

### Wallpapers
- Wallpaper collection: per-theme wallpaper sets
- Animated wallpapers via `swww` with transition effects
- Wallpaper rotation (time-of-day or random)

### Lock Screen
- hyprlock theming: Dracula/Tokyo Night lock screen
- Custom layout: clock, user avatar, input field styling
- Idle timeout configuration (hypridle)

### Plugins
- Evaluate additional plugins:
  - `hyprtrails` -- cursor trails (aesthetic)
  - `hypr-dynamic-cursors` -- cursor size/shape changes
  - `borders-plus-plus` -- extra border effects
  - `hyprspace` -- macOS-like overview
- Performance impact assessment for each plugin

### Layout & Workspace Rules
- Workspace-specific layouts and rules
- Per-workspace default applications

---

## Follow-Up E: Development Environment

**Goal:** Complete development tooling -- project templates, containers, security, remote access.

### Nix Development
- Per-project nix flake templates:
  - Rust (with cargo, clippy, rustfmt)
  - Python (with venv, poetry/uv)
  - Node (with pnpm/yarn)
  - Go (with gopls, golangci-lint)
- Shared `flake.nix` template with common dev shell utilities
- `nix-direnv` integration for automatic environment activation

### Git & Code Quality
- Git hooks via Nix (pre-commit framework)
  - Formatters: alejandra (Nix), prettier, black, rustfmt
  - Linters: statix (Nix), eslint, clippy
  - Commit message validation (conventional commits)
- `git-absorb` for automatic fixup commits
- `difftastic` as alternative diff tool

### Database Tools
- `pgcli` -- PostgreSQL with autocomplete and syntax highlighting
- `mycli` -- MySQL equivalent
- `usql` -- universal SQL client
- `dbmate` or `sqitch` for migrations

### Container Tools
- Docker / Podman configuration
- `lazydocker` -- terminal UI for Docker
- `dive` -- explore Docker image layers
- `ctop` -- container metrics

### API & HTTP Tools
- `httpie` tuning (themes, default headers)
- `xh` -- httpie-compatible with better defaults
- `grpcurl` for gRPC APIs
- `websocat` for WebSocket debugging

### Remote Access
- SSH config management via home-manager `programs.ssh`
  - Host aliases, jump hosts, key management
  - Per-host settings
- ~~GPG key management via home-manager `programs.gpg`~~ **DONE** (agent + pinentry + git signing workflow on maverick)
  - ~~Signing commits~~ **DONE**
  - Password store integration -- **PARTIAL** (`rbw` workflow documented; full backup/export policy deferred)

---

## Follow-Up F: System-Level Enhancements

**Goal:** OS-level configuration, automation, security, and maintenance.

### NixOS (maverick)
- ~~Systemd services: custom user services for background tasks~~ **DONE** (emacs daemon, flake-update timer)
- ~~Power management: TLP for laptop battery optimization~~ **DONE** (battery thresholds, CPU governors, WiFi power saving, USB autosuspend)
- ~~Plymouth boot splash (Dracula themed)~~ **DONE** (bgrt manufacturer logo with systemd initrd)
- Secure boot (lanzaboote) -- **DEFERRED**

### nix-darwin (iceman) -- **DEFERRED** (to be done on the Mac)
- Additional system defaults (`defaults write` equivalents)
  - Dock: autohide, icon size, minimize effect
  - Finder: show extensions, default view, sidebar items
  - Keyboard: key repeat rate, initial delay
  - Trackpad: tap-to-click, natural scrolling
- Launchd services for background automation
- Spotlight alternatives (Raycast via Homebrew if needed)

### Automation
- ~~Automatic updates strategy:~~ **DONE** (weekly systemd timer, Sundays 09:00)
- ~~CI: GitHub Actions for `nix flake check` on push~~ **DONE** (.github/workflows/check.yml)
- Nix binary cache (cachix) -- **SKIPPED** (not worth it for 2-machine personal setup)
- Host rename cleanup -- **TODO after both machines are converted**
  - Remove flake aliases: `carbon`, `macmini`, `bryansmacmini`, `nixos`
  - Remove home-manager aliases: `bclark@carbon`, `bclark@macmini`, `bclark@bryansmacmini`
  - Remove the `macmini-remote` compatibility wrapper and keep `iceman-remote` only

### Security
- ~~Secrets management: `agenix`~~ **DONE** (flake input, NixOS module, secrets/ directory with template)
  - Encrypt: SSH keys, API tokens, WiFi passwords
  - Decrypt at activation time, not in Nix store
- ~~Firewall configuration (NixOS)~~ **DONE** (SSH-only inbound, all else dropped)
- ~~CVE monitoring~~ **DONE** (vulnix installed, run `vulnix --system`)

### Backup -- **DEFERRED**
- Backup strategy:
  - `restic` or `borgbackup` via NixOS/home-manager modules
  - What to back up: home dir, Nix config, secrets
  - Where: remote server, cloud storage (B2, S3)
  - Schedule: daily incremental, weekly full
  - Retention policy: 7 daily, 4 weekly, 6 monthly
- Disaster recovery: document full rebuild from scratch procedure

---

## Priority Order

Recommended order based on impact and dependencies:

1. **Follow-Up C** (Terminal & Shell) -- **DONE**
2. **Follow-Up E** (Development) -- **DONE**
3. **Follow-Up A** (VS Code) -- **MOSTLY DONE**: Emacs MCX with conflict resolution (Ctrl+B/P context-aware), Emacs-style keybindings (M-x, C-x C-f, C-x 2/3/o/1/k), Copilot/Claude Code with settings, markdown-all-in-one, two-layer extensions. REMAINING: snippets, task configurations
4. **Follow-Up B** (Browser) -- **DONE**: arkenfox-style Firefox hardening, dual profiles, all privacy extensions, xBrowserSync, Chromium privacy flags, documented in README
5. **Follow-Up D** (Hyprland Rice) -- **MOSTLY DONE**: Dracula theming, animations, swww wallpaper, dropdown terminal, window rules, waybar with hover/transitions/urgent pulse, wofi with icons/fuzzy, dunst with progress bars/history/per-app rules, hyprlock Dracula lock screen, hypridle dim→lock→dpms chain. REMAINING: plugins (hyprexpo broken), wallpaper collection
6. **Follow-Up F** (System-Level) -- **MOSTLY DONE**: TLP, firewall, plymouth, agenix, vulnix, emacs daemon, CI, flake update timer. DEFERRED: secure boot, backups, macOS defaults
