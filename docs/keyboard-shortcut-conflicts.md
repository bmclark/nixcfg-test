# Keyboard Shortcut Conflicts

This file inventories current or likely user-facing shortcut conflicts based on the configured bindings in this repo. It is a follow-up list, not a resolution document.

## Confirmed Conflicts And Friction

| Binding | Tools involved | Current behavior | User impact | Follow-up direction |
|---------|----------------|------------------|-------------|---------------------|
| `Ctrl+A` | tmux, zsh | tmux captures it as prefix before the shell can use beginning-of-line | New users may think shell line editing is broken inside tmux | Keep documenting `Ctrl+A Ctrl+A` or consider a different prefix if this remains painful |
| `Cmd+Q` on macOS | Karabiner, macOS apps | `Cmd` is remapped to `Ctrl`, so macOS quit behavior does not trigger normally | Native macOS muscle memory breaks, especially for quitting apps | Decide whether to keep this deliberate friction or add app-specific exceptions |
| `vi` movement in copy mode vs Emacs shell editing | tmux, zsh | tmux copy mode uses `vi`, shell editing stays Emacs-style | Users must switch mental model when entering copy mode | Decide whether documentation is enough or whether copy-mode remapping is worthwhile |

## High-Confidence Cross-App Collisions

| Binding | Tools involved | Current behavior | User impact | Follow-up direction |
|---------|----------------|------------------|-------------|---------------------|
| `Ctrl+Alt+B/F/P/N` | Hyprland, Emacs-style app navigation | Hyprland uses these globally for window focus movement | Emacs and other apps can lose access to familiar `Ctrl+Meta` navigation patterns | Evaluate whether global directional focus should move to different bindings |
| `Ctrl+Alt+Shift+B/F/P/N` | Hyprland, app/editor keyspaces | Hyprland uses these globally for moving windows | Rare, but can shadow app-level modified movement bindings | Review only if this becomes a real annoyance |
| `Alt+Left/Right/Up/Down` | tmux, terminal apps | tmux uses them for pane movement | Terminal apps that want Alt-arrow behavior may not receive it inside tmux | Consider a pane-navigation scheme that is less invasive if conflicts keep surfacing |
| `Shift+Left/Right` | tmux, terminal selection behavior | tmux uses them for window switching | Users expecting selection-extension behavior in terminal apps may get window switches instead | Revisit only if this interferes with actual workflows |
| `Ctrl+Shift+Left/Right/Up/Down` | tmux, terminals, shells, apps | tmux uses them for pane resizing | Can collide with terminal or app selection/navigation shortcuts | Monitor before changing; currently coherent inside tmux |
| `Ctrl+Tab` / `Ctrl+Shift+Tab` | Ghostty, terminal apps, Emacs in terminal | Ghostty uses these for tab switching | Terminal apps running in Ghostty may not receive those keys | Decide whether Ghostty tab switching should stay on these defaults |
| `Ctrl+Shift+W` | Ghostty, browsers, GUI apps inside terminal expectations | Ghostty closes the current surface/tab | Similar to browser tab close, but dangerous if used reflexively in the wrong context | Keep documented; low urgency unless accidental closes become common |
| `Alt+Tab` | Hyprland, application-local switching expectations | Hyprland uses it for desktop window cycling | Some apps also treat Alt/Tab specially, but Hyprland wins at desktop scope | Probably acceptable; document as desktop-level behavior |

## Non-Conflicts Worth Keeping Explicit

These are not bugs, but users can mistake them for bugs:

| Topic | Why it matters |
|-------|----------------|
| Ghostty has no auto-logging | Users may expect terminal logs automatically; tmux logging is the intended solution |
| Dropdown terminal vs normal terminal windows | `Super+\`` is for quick transient access, not the main persistent workspace |
| Hyprland workspaces vs tmux windows vs Emacs workspaces | Each layer solves a different navigation problem; mixing them casually makes the setup feel harder than it is |

## Maintenance Rule

Whenever a shortcut changes in Hyprland, Ghostty, tmux, shell bindings, Emacs, or Karabiner-related behavior, update this inventory if the change introduces, removes, or clarifies a conflict.
