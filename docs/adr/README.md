# Architecture Decision Records (ADRs)

This directory stores Architecture Decision Records that capture significant choices in this configuration. Each ADR explains the context, the decision made, and the resulting consequences so future changes can reference prior rationale.

## Format
Every ADR follows a consistent structure:
- **Status**: Accepted, Proposed, Deprecated, or Superseded
- **Date**: When the decision was recorded
- **Context**: The problem or motivation
- **Decision**: The selected approach and implementation notes
- **Consequences**: Positive, negative, and neutral outcomes

## Index
- [ADR-001: Architecture and Modularization Strategy](ADR-001-architecture-and-modularization.md)
  Feature-based modules with enable flags, platform separation, and integrated home-manager.
- [ADR-002: Shell and Terminal Choices](ADR-002-shell-and-terminal-choices.md)
  zsh + Starship (P10k-style) and Ghostty across platforms with CLI integrations.
- [ADR-003: Keyboard Remapping Strategy](ADR-003-keyboard-remapping-strategy.md)
  Ctrl for application shortcuts, Super for window management, Karabiner remapping on macOS.
- [ADR-004: Theme Standardization (Dracula)](ADR-004-theme-standardization.md)
  Dracula palette applied to Hyprland, Ghostty, fzf, bat, Emacs, and Starship.
- [ADR-005: Development Environment Approach](ADR-005-development-environment-approach.md)
  Per-project nix-shell environments with minimal system-wide tooling.
- [ADR-006: Build Automation with Justfile](ADR-006-build-automation-with-justfile.md)
  Comprehensive justfile covering platform-specific commands, maintenance, and tooling.
- [ADR-008: Tmux Integration and Session Logging](ADR-008-tmux-integration.md)
  Tmux with Dracula theme, Ctrl+A prefix, tmux-logging for session capture.
- [ADR-009: Browser Strategy](ADR-009-browser-strategy.md)
  Firefox primary (privacy extensions), Chromium fallback (minimal extensions).
- [ADR-010: Shell Plugin Management](ADR-010-shell-plugin-management.md)
  Home-manager native zsh plugins, no external plugin manager.
- [ADR-012: Switchable Theme System](ADR-012-switchable-theme-system.md)
  Custom palette files with justfile rebuild command for theme switching.
- [ADR-013: Documentation Maintenance for User Guides](ADR-013-documentation-maintenance-for-user-guides.md)
  Hybrid onboarding plus feature guides, with explicit maintenance rules for docs and shortcut conflicts.

## Creating New ADRs
When documenting new decisions:
1. Create `ADR-XXX-short-title.md` with the next sequential number.
2. Follow the standard format described above.
3. Reference relevant code modules and related ADRs.
4. Update this index with the new entry.

## Related Documentation
- [Main Documentation Index](../README.md)
- [Keyboard Layout Strategy](../keyboard-layout-strategy.md)
- [Dotfiles Migration Strategy](../dotfiles-migration.md)
