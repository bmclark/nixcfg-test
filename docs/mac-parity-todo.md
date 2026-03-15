# macOS Parity — Deferred Work

Items outside the terminal + editors focus of the initial parity work (ADR-014).

## To Do

- [ ] **Tailscale:** add `tailscale` cask to `homebrew.nix` for macOS menu bar app
- [ ] **pueue:** investigate whether `services.pueue` needs a launchd guard on Darwin
- [ ] **fontconfig:** investigate `fonts.fontconfig` options on Darwin (may need platform guard)
- [ ] **macOS-native OCR:** implement OCR functions using `screencapture` + `tesseract` as alternatives to the Linux/Wayland OCR helpers (`ocrimg`, `ocrpdf`, `ocrshot`)
