# macOS Parity — Deferred Work

Items outside the terminal + editors focus of the initial parity work (ADR-014).

## Completed

- [x] **Tailscale:** added `tailscale` cask to `homebrew.nix`
- [x] **pueue:** added `lib.mkIf pkgs.stdenv.isLinux` guard for systemd service
- [x] **fontconfig:** verified `fonts.fontconfig` works cross-platform via home-manager (no guard needed)
- [x] **macOS-native OCR:** skipped — macOS Live Text (built into Preview, Quick Look, Screenshot) covers this natively
- [x] **Screen Sharing:** replaced ARD Remote Management with plain VNC Screen Sharing for Linux Remmina access
- [x] **Dock defaults:** scale effect, minimize-to-application, hot corners (lock/note/desktop/sleep)
- [x] **Finder defaults:** home window, disable extension warning, show desktop icons, search current folder
- [x] **Power management:** never sleep, display 60min, auto-restart after power failure
- [x] **Mission Control:** disabled gestures and keyboard shortcuts for Aerospace
- [x] **Stage Manager:** disabled
- [x] **.DS_Store:** disabled on network and USB volumes
- [x] **FileVault:** status check during darwin-switch

## Deferred

- [ ] **Multi-monitor AeroSpace config**
- [ ] **Backup strategy:** restic or borgbackup
- [ ] **Secure Boot:** lanzaboote on NixOS
