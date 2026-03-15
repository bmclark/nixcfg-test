# ADR-009: Browser Strategy

**Status**: Accepted
**Date**: 2026-03-14

## Context

The configuration needs declaratively managed browsers on both NixOS and macOS with:
- Strong privacy defaults
- Dracula theming consistency
- Password management (Bitwarden)
- Fallback option for sites that break under strict privacy settings

## Decision

**Firefox as primary browser** (privacy-focused) with **Chromium as fallback**.

### Firefox
- Force-installed extensions via policies (no user intervention needed):
  - **uBlock Origin**: ad/tracker blocking
  - **Privacy Badger**: learns to block invisible trackers
  - **Bitwarden**: password management
  - **Dracula theme**: browser UI theming
  - **Dark Reader**: dark mode for all websites
  - **LocalCDN**: CDN emulation for privacy
  - **ClearURLs**: strip tracking parameters
  - **Cookie AutoDelete**: auto-clear cookies after tab close
  - **Multi-Account Containers**: isolate browsing contexts
  - **CanvasBlocker**: anti-fingerprinting
- Strict tracking protection with cryptomining/fingerprinting blocking
- Telemetry, Pocket, Firefox accounts all disabled
- All other extensions blocked by default

### Chromium
- Minimal setup: Bitwarden, Dracula theme, Dark Reader
- Used only when Firefox privacy extensions break specific sites
- Enabled on both platforms

## Consequences

**Positive**
- Privacy-by-default browsing experience
- Consistent Dracula theming across both browsers
- Declarative extension management (no manual installs)
- Fallback browser available when strict privacy settings cause issues

**Negative**
- Some sites may require switching to Chromium
- Firefox policy-based extension management is less flexible than manual installs
- Managing two browser configurations adds maintenance

**Neutral**
- Extension IDs must be looked up from AMO/Chrome Web Store
- Chromium extensions use Chrome Web Store IDs in `programs.chromium.extensions`
