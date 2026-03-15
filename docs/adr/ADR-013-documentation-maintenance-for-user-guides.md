# ADR-013: Documentation Maintenance for User Guides

**Status**: Accepted
**Date**: 2026-03-15

## Context

This repository already has feature READMEs, deeper guides, and ADRs, but the user-facing documentation has grown unevenly. Some docs explain architecture well, while others are too maintainer-oriented for someone brand new to the system. Keyboard-driven workflows also span multiple layers: Hyprland, Ghostty, tmux, Emacs, shell editing, and macOS remapping. When one layer changes without updating the docs, the system becomes harder to learn and harder for AI agents to modify safely.

Two needs are now explicit:
- beginner-first guides that explain what each major tool is for and how to move within it
- a durable policy requiring AI agents and maintainers to update those guides whenever user-facing behavior changes

## Decision

Adopt a **hybrid documentation model** with an explicit maintenance policy.

### Documentation structure

- `docs/system-user-guide.md` is the central onboarding document for new users.
- Feature READMEs under `home/features/` remain the canonical detailed user guides for their area.
- Deep, tool-specific manuals can continue to live beside the feature, such as `home/features/editors/GUIDE.md`.
- `docs/keyboard-shortcut-conflicts.md` is the canonical inventory of current and likely shortcut conflicts.

### Maintenance contract

When a change affects user-facing behavior, the same change must update the relevant documentation:

- update the feature README when adding, removing, or materially changing a tool, workflow, keybinding, alias, or interaction model
- update `docs/system-user-guide.md` when the beginner mental model or cross-tool workflow changes
- update `docs/keyboard-shortcut-conflicts.md` when a shortcut conflict is introduced, removed, or clarified
- update deeper guides when behavior documented there changes materially

### Required content for user guides

User-facing guides should describe:
- what the tool or subsystem is for
- when to use it instead of adjacent tools
- how to move within it: windows, panes, tabs, buffers, workspaces, or prompts as appropriate
- key shortcuts or commands needed for normal daily use

### Agent enforcement

`docs/agents.md` must contain explicit instructions that make these documentation updates part of the expected deliverable for AI agents.

## Consequences

**Positive**
- New users get one clear entry point and deeper guides where needed
- Feature docs become more useful for actual daily operation, not just repo orientation
- Keyboard changes become easier to audit because conflict tracking is explicit
- AI agents have a concrete rule to follow instead of relying on implied norms

**Negative**
- User-facing changes now carry extra documentation work
- Shortcut-heavy features require more careful doc maintenance than before

**Neutral**
- ADRs still capture rationale, but they are not the primary user guide
- Some overlap between the central guide and feature READMEs is acceptable if the central guide stays high-level
