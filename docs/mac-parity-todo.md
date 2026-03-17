# macOS Parity Status

Current checkpoint for the Darwin work tracked by ADR-014 and the follow-on Aerospace/Karabiner changes.

## Landed

- [x] **Homebrew parity:** declarative casks and MAS apps captured in `darwin/common/homebrew.nix`, including Aerospace, Karabiner-Elements, Raycast, Tailscale, Ghostty, and Google Chrome
- [x] **Aerospace window management:** enabled on `iceman`, fed by shared workspace assignments from `home/features/desktop/keybindings.nix`
- [x] **Aerospace autostart:** `start-at-login = true` is now rendered in `aerospace.toml`
- [x] **Karabiner remapping:** CapsLock sends plain `Ctrl`, physical `Ctrl` sends `Hyper`, and the mapping order avoids CapsLock chaining into Hyper
- [x] **Karabiner login agent:** nix-darwin launches the Karabiner non-privileged agents app at login
- [x] **Tailscale:** `tailscale` cask declared in `homebrew.nix`
- [x] **pueue:** Linux-only systemd service guard added so macOS activation stays clean
- [x] **fontconfig:** verified `fonts.fontconfig` works cross-platform via home-manager
- [x] **macOS-native OCR:** intentionally skipped because Live Text in Preview, Quick Look, and Screenshot already covers this
- [x] **Screen Sharing:** replaced ARD Remote Management with plain VNC Screen Sharing for Linux Remmina access
- [x] **Dock defaults:** scale effect, minimize-to-application, and hot corners (lock / note / desktop / sleep)
- [x] **Finder defaults:** home window, no extension warning, desktop icons visible, search current folder
- [x] **Power management:** never sleep, display 60 minutes, restart after power failure / freeze
- [x] **Mission Control:** keyboard shortcuts and relevant gestures disabled so Aerospace owns workspace movement
- [x] **Stage Manager:** disabled
- [x] **.DS_Store:** disabled on network and USB volumes
- [x] **FileVault visibility:** status check emitted during `darwin-switch`

## Still Deferred

- [ ] **Multi-monitor Aerospace config**
- [ ] **Backup strategy:** restic or borgbackup
- [ ] **Secure Boot:** lanzaboote on NixOS

## Notes

- Karabiner still requires manual Accessibility and Input Monitoring approval in System Settings after install.
- macOS GUI shortcuts stay native: app switching is still `Cmd+Tab`, and copy/paste in GUI apps is still `Cmd+C/V/X`.
- The shared window-manager layer now uses `Hyper` on both hosts; in practice that is the physical `Ctrl` key.

## App Parity Snapshot

Installed on both hosts through Nix first:
- `gemini-cli`
- Bitwarden desktop / Bitwarden app
- Spotify
- Audacity

Still not shared declaratively on `maverick`:
- Future todo: add `tdd-guard` on `maverick` if Linuxbrew support is introduced to this repo
- `Claude` desktop app is macOS-only
- `ChatGPT` desktop app is macOS-only
- Aerospace, Karabiner-Elements, Raycast, Logitech G Hub, Safari, and the Mac App Store apps remain mac-only
