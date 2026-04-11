# Keyboard Shortcut Conflicts

This file inventories current or likely user-facing shortcut conflicts based on the configured bindings in this repo. It is a follow-up list, not a resolution document.

## Confirmed Conflicts And Friction

| Binding | Tools involved | Current behavior | User impact | Follow-up direction |
|---------|----------------|------------------|-------------|---------------------|
| `CapsLock+A` | tmux, zsh | tmux keeps logical `Ctrl+A` as a backup prefix while `CapsLock+]` becomes primary | Shell line editing inside tmux still needs `CapsLock+A CapsLock+A` for a literal beginning-of-line as long as the backup prefix remains enabled | Remove the backup prefix later if it becomes more confusing than useful |
| `CapsLock+Shift+W` | Ghostty, shell muscle memory, browser muscle memory | Ghostty closes the current surface/tab immediately | Similar to browser tab close, but easy to hit reflexively in the wrong context | Accept; low urgency because close confirmation is intentionally disabled |

## High-Confidence Cross-App Collisions

| Binding | Tools involved | Current behavior | User impact | Follow-up direction |
|---------|----------------|------------------|-------------|---------------------|
| `Shift+Left/Right` | tmux, terminal selection behavior | tmux uses them for tmux window switching | Users expecting selection-extension behavior in terminal apps may get tmux window changes instead | Accept for now because this preserves long-standing upstream muscle memory |
| `Shift+Down` | tmux, terminal selection behavior | tmux uses it for new-window | Users expecting selection-extension behavior may open a new tmux window instead | Accept for now because this preserves long-standing upstream muscle memory |
| `Alt+Tab` | Hyprland, application-local switching expectations | Hyprland uses it for desktop window cycling | Some apps also treat Alt/Tab specially, but Hyprland wins at desktop scope | Probably acceptable; document as desktop-level behavior |

## CUA Mode And keyd super_cua Interactions

| Topic | Tools involved | Behavior | Impact | Notes |
|-------|---------------|----------|--------|-------|
| `Super+C` in Emacs | keyd, Emacs CUA mode | keyd sends `C-c`; CUA mode copies if region active, prefix otherwise | Works as expected for copy/paste. Prefix keys (`C-c C-c`, `C-c l`, etc.) are unaffected when no region is active | If CUA mode's context-switching causes confusion, consider a Hyprland IPC monitor to toggle keyd layers per-app |
| `Super+X` in Emacs | keyd, Emacs CUA mode | keyd sends `C-x`; CUA mode cuts if region active, prefix otherwise | `C-x C-s` (save) works when no region is active. With region, first `C-x` cuts | Same as above — CUA mode handles context |
| `Super+V` in Emacs | keyd, Emacs CUA mode | keyd sends `C-v`; CUA mode pastes (overrides scroll-up) | `C-v` no longer scrolls up — use `PgDn` or mouse wheel | Accepted trade-off for cross-platform paste consistency |
| `Super+C/V/X` in VS Code | keyd, emacs-mcx | keyd sends `Ctrl+C/V/X`; emacs-mcx does NOT remap these | No conflict — native VS Code copy/paste | emacs-mcx only touches `C-a/e/k/n/p/f/b` |
| `Super+C/V/X` in Ghostty | keyd, Ghostty | keyd sends `Ctrl+C/V/X`; Ghostty uses `Ctrl+Shift+C/V` for copy/paste | `Super+C` sends SIGINT in Ghostty (same as `Ctrl+C`); copy requires `Ctrl+Shift+C` (i.e., `CapsLock+Shift+C`) | Expected — terminal copy/paste uses Ctrl+Shift convention |

## Disabled macOS Accessibility Shortcuts

The following macOS accessibility shortcuts are disabled via `AppleSymbolicHotKeys` because physical Ctrl maps to Hyper (Ctrl+Alt+Cmd) via Karabiner, causing collisions:

| HotKey ID | macOS shortcut | Conflict | Resolution |
|-----------|---------------|----------|------------|
| 12 | Ctrl+Opt+Cmd+8 | Invert Colors triggered by physical Ctrl+8 (workspace 8) | Disabled |
| 15 | Ctrl+Opt+Cmd+= | Zoom In triggered by Hyper+= | Disabled |
| 17 | Ctrl+Opt+Cmd+- | Zoom Out triggered by Hyper+- | Disabled |
| 19 | Ctrl+Opt+Cmd+0 | Zoom Toggle triggered by physical Ctrl+0 (workspace 10) | Disabled |

## Workspace Cycling vs Window Focus (Cross-Platform)

Arrows cycle workspaces, comma/period focus windows — consistent across macOS and Hyprland:

| Physical key | macOS (Aerospace) | Linux (Hyprland) | Purpose |
|-------------|-------------------|-------------------|---------|
| Ctrl+Left/Right | Workspace cycle prev/next | Workspace r-1/r+1 | Desktop switching |
| Ctrl+,/. | Focus left/right | movefocus l/r | Window focus within workspace |
| Ctrl+Shift+Left/Right | Move window to prev/next workspace | movetoworkspace r-1/r+1 | Send window to adjacent workspace |
| Ctrl+Shift+,/. | Move window left/right (spatial) | movewindow l/r | Rearrange window within workspace |
| Ctrl+Up/Down | Focus up/down | movefocus u/d | Vertical window focus |
| Ctrl+Shift+Up/Down | Move window up/down | movewindow u/d | Vertical window rearrangement |

## Non-Conflicts Worth Keeping Explicit

These are not bugs, but users can mistake them for bugs:

| Topic | Why it matters |
|-------|----------------|
| Hyper bindings | The dedicated Hyper layer intentionally avoids app collisions; physical `Ctrl` is reserved for WM duties and no longer sends plain `Ctrl` |
| macOS app switching | AltTab now provides physical `Alt+Tab` app switching on macOS; native `Cmd+Tab` still exists alongside it |
| Ghostty has no auto-logging | Users may expect terminal logs automatically; tmux logging is the intended solution |
| tmux mouse copy | Mouse selection is enabled in tmux and copies through the clipboard integration rather than only selecting visually |
| Linux dropdown terminal vs macOS scratch workspace | `CapsLock+\`` toggles a guake-style dropdown terminal on Linux but `Ctrl+\`` toggles a Ghostty-backed scratch workspace `S` on macOS |
| Hyprland workspaces vs tmux windows vs Emacs workspaces | Each layer solves a different navigation problem; mixing them casually makes the setup feel harder than it is |

## Maintenance Rule

Whenever a shortcut changes in Hyprland, Ghostty, tmux, shell bindings, Emacs, or Karabiner-related behavior, update this inventory if the change introduces, removes, or clarifies a conflict.
