# macOS Parity — Deferred Work

Items outside the terminal + editors focus of the initial parity work (ADR-014).

## Completed

- [x] **Tailscale:** added `tailscale` cask to `homebrew.nix`
- [x] **pueue:** added `lib.mkIf pkgs.stdenv.isLinux` guard for systemd service
- [x] **fontconfig:** verified `fonts.fontconfig` works cross-platform via home-manager (no guard needed)
- [x] **macOS-native OCR:** skipped — macOS Live Text (built into Preview, Quick Look, Screenshot) covers this natively
