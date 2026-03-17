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

## Non-Conflicts Worth Keeping Explicit

These are not bugs, but users can mistake them for bugs:

| Topic | Why it matters |
|-------|----------------|
| Hyper bindings | The dedicated Hyper layer intentionally avoids app collisions; physical `Ctrl` is reserved for WM duties and no longer sends plain `Ctrl` |
| macOS app switching | AltTab now provides physical `Alt+Tab` app switching on macOS; native `Cmd+Tab` still exists alongside it |
| Ghostty has no auto-logging | Users may expect terminal logs automatically; tmux logging is the intended solution |
| tmux mouse copy | Mouse selection is enabled in tmux and copies through the clipboard integration rather than only selecting visually |
| Linux dropdown terminal vs macOS scratch workspace | `Hyper+\`` toggles a dropdown terminal on Linux but toggles a Ghostty-backed scratch workspace `S` on macOS |
| Hyprland workspaces vs tmux windows vs Emacs workspaces | Each layer solves a different navigation problem; mixing them casually makes the setup feel harder than it is |

## Maintenance Rule

Whenever a shortcut changes in Hyprland, Ghostty, tmux, shell bindings, Emacs, or Karabiner-related behavior, update this inventory if the change introduces, removes, or clarifies a conflict.
