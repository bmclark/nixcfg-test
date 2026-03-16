# Desktop Features

Window manager, Wayland desktop services, browsers, fonts, and keyboard remapping for the graphical environment.

## Start Here

On the NixOS laptop (`carbon`), the desktop is built around **Hyprland**:
- Hyprland manages windows and workspaces.
- Waybar shows status and workspace state.
- Wofi launches apps.
- Dunst handles notifications.
- Hyprlock locks the screen.
- Ghostty is the main terminal app.

On the macOS host (`macmini`), Hyprland is not used. The main desktop-specific behavior is Karabiner remapping `Cmd` to `Ctrl` so application shortcuts match the Linux setup more closely.

## What To Use When

| Tool | Use it for | Prefer it over |
|------|------------|----------------|
| Hyprland | Moving windows, switching workspaces, layout control, locking, screenshots | Using app-level tabs or panes to simulate OS-level workspace management |
| Wofi | Launching apps quickly | Digging through menus |
| Waybar | Seeing workspace state, media, battery, network, bluetooth, audio | Opening multiple settings panels just to check status |
| Hyprlock | Locking the session | Logging out when you only need to step away |
| Firefox | Primary browser with stronger privacy defaults | Chromium for normal daily browsing |
| Chromium | Compatibility fallback | Firefox when a site is broken or requires Chromium behavior |
| Karabiner | macOS key remapping for app shortcuts | Per-app remapping by hand |
| Remmina | Remote desktop sessions such as the Mac Screen Sharing setup | Ad hoc VNC command lines when you want saved profiles or a GUI |

## Desktop Movement And Navigation

### Hyprland basics

These bindings are the main way to move around the graphical desktop on `carbon`.

| Key | Action |
|-----|--------|
| `Super+Return` | Open a new terminal |
| `Super+D` | Open the app launcher |
| `Super+E` | Open Thunar |
| `Super+Space` | Toggle floating for the current window |
| `Super+F` | Toggle fullscreen |
| `Super+L` | Lock screen |
| `Super+Escape` | Open logout/power menu |
| `Super+\`` | Toggle the dropdown terminal |
| `Super+,` / `Super+.` | Previous / next workspace |
| `Super+1` .. `Super+0` | Switch to workspace 1..10 |
| `Super+Shift+1` .. `Super+Shift+0` | Move current window to workspace 1..10 |
| `Alt+Tab` / `Alt+Shift+Tab` | Cycle windows forward / backward |
| `Alt+F4` | Close active window |
| `Ctrl+Alt+B/F/P/N` | Focus window left / right / up / down |
| `Ctrl+Alt+Shift+B/F/P/N` | Move window left / right / up / down |
| `Super+Shift+S` | Area screenshot |
| `Super+Shift+Print` | Full screenshot |
| `Super+Ctrl+S` | Area screenshot and annotate in Swappy |
| `Super+Ctrl+O` | OCR selected screen region to clipboard |
| `Super+V` | Clipboard history picker |
| `Super+Shift+C` | Pick a screen color to the clipboard |

Mouse actions:

| Key | Action |
|-----|--------|
| `Super+Left click drag` | Move window |
| `Super+Right click drag` | Resize window |
| `Super+mouse wheel` | Cycle workspaces |

Touchpad:

| Gesture | Action |
|---------|--------|
| Three-finger horizontal swipe | Change workspace |

### Workspaces and automatic placement

Some apps are placed on fixed workspaces:

| Workspace | App |
|-----------|-----|
| `1` | Emacs |
| `2` | Firefox |
| `3` | VS Code |

That means a good default workflow is:
- `Super+1` for editing/writing in Emacs
- `Super+2` for browser work
- `Super+3` for VS Code if needed
- use later workspaces for project-specific terminals, chat, or misc apps

### Dropdown terminal

`Super+\`` opens a terminal on a special hidden workspace that drops down from the top of the screen.

Use it for:
- quick commands
- short notes
- one-off git or system checks

Do not treat it as your main long-lived work area; that is better handled by a normal Ghostty window with tmux inside.

## Browsers

### Firefox

Firefox is the primary browser.

| Profile | Launch | Use for |
|---------|--------|---------|
| `default` | `firefox` | Day-to-day browsing with the strongest privacy defaults |
| `relaxed` | `firefox -P relaxed` | Sites that break under hardened settings |

Shared extensions include Bitwarden, uBlock Origin, Privacy Badger, Dracula, Dark Reader, and xBrowserSync.

### Chromium

Chromium is the compatibility browser. Use it when:
- a site needs Chromium-specific behavior
- DRM/video behavior differs
- enterprise tooling is unreliable in Firefox

## Remote Desktop

`carbon` includes Remmina for remote desktop sessions.

For the macOS Screen Sharing setup in this repo:
- launch Remmina from Wofi for a GUI workflow
- or run `macmini-remote` in a shell
- pass a Tailscale IP if MagicDNS is not resolving: `macmini-remote 100.x.y.z`

The helper defaults to `macmini`, which matches the macOS host name managed in the Darwin config.
Authenticate the Mac to Tailscale from the menu bar app on `macmini`; the Linux side only needs the reachable host name or Tailscale IP.

## Desktop Services

### Waybar

Waybar surfaces workspaces, the active window, media, system stats, bluetooth, network, audio, battery, tray, weather, and clock.

Use it as the desktop dashboard:
- check workspace occupancy before switching
- verify bluetooth/network/audio state quickly
- watch battery and media state without opening extra apps

### Dunst

Dunst provides notifications with history and app-specific rules.

Useful behaviors:
- notification history is available through `dunstctl history-pop`
- left click triggers the default action
- middle click closes all notifications
- right click closes the current notification

### Thunar and removable media

Thunar is the lightweight graphical file browser on `carbon`.

Use it for:
- browsing directories visually
- opening and ejecting USB/thumb drives
- quick archive handling through the archive plugin
- opening a terminal in the selected directory
- copying full file paths from the context menu
- running OCR on selected images or PDFs from the context menu

Removable media is automounted by `udiskie`, so mounted drives should show up in Thunar automatically.

### OCR and document helpers

`carbon` includes a lightweight OCR workflow:
- `ocrshot` or `Super+Ctrl+O` grabs a screen region, OCRs it, and copies the text
- `ocrimg <file>` OCRs an image and copies the text
- `ocrpdf <file> [page]` OCRs a PDF page and copies the text
- `zathura <file.pdf>` opens PDFs in a keyboard-friendly viewer

### Hyprlock and idle flow

The session follows a staged idle chain:
- screen dims after 5 minutes
- lock engages after 15 minutes
- displays power down after 20 minutes

Use `Super+L` when leaving the machine instead of waiting for idle.

## macOS Notes

Karabiner remaps both `Cmd` keys to `Ctrl`. The point is consistency for application shortcuts, not to make macOS behave exactly like Hyprland.

Practical effect:
- `Cmd+C` behaves like `Ctrl+C`
- `Cmd+V` behaves like `Ctrl+V`
- `Cmd+S` behaves like `Ctrl+S`
- native macOS shortcuts that expect real `Cmd`, especially quit behavior, may no longer act normally

See [ADR-003](../../../docs/adr/ADR-003-keyboard-remapping-strategy.md) and [docs/keyboard-layout-strategy.md](../../../docs/keyboard-layout-strategy.md).

## Platform Notes

- **Chromium:** Linux-only (`pkgs.chromium` is not available on aarch64-darwin). On macOS, Google Chrome is installed via Homebrew cask (`darwin/common/homebrew.nix`) as the Chromium replacement.
- **Firefox:** available on both platforms via nixpkgs.

## Design Notes

- Hyprland owns window and workspace movement; tmux and Emacs should not be used as substitutes for desktop-level workspace switching.
- Use Ghostty tabs sparingly and tmux heavily if you want durable terminal workflows.
- The keyboard model is intentionally split: `Ctrl` for apps, `Super` for window management.
- Browser strategy is Firefox first, Chromium second.

See [ADR-003](../../../docs/adr/ADR-003-keyboard-remapping-strategy.md), [ADR-007](../../../docs/adr/ADR-007-hyprland-configuration-modernization.md), [ADR-009](../../../docs/adr/ADR-009-browser-strategy.md), and [ADR-014](../../../docs/adr/ADR-014-macos-platform-parity.md).
