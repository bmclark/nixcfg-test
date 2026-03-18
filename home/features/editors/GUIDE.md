# Emacs User Guide

A practical guide to using this Emacs configuration for coding (IDE), writing (prose/docs), and task management (org-mode). If you've used VS Code, many concepts will feel familiar -- this config mirrors VS Code's layout and keybindings where possible.

## Getting Started

### Opening Emacs

Emacs runs as a background daemon (systemd service). You never launch "Emacs" directly:

```sh
emacsclient -c          # Open a new GUI frame (instant)
emacsclient -t          # Open in current terminal
emacsclient -c file.py  # Open a file directly
```

The daemon preserves all your buffers, terminals, and state between frames. Closing a frame (`C-x 5 0`) doesn't quit Emacs -- your work continues in the background.

### First Launch

After `just switch` (Nix rebuild), the first launch takes a minute:

1. `use-package` auto-downloads ~40 packages from MELPA
2. Native compilation (`eln-cache`) runs in the background
3. Once complete, subsequent launches are instant

### The Interface

```
+--treemacs--+-------editor-tabs--------+--symbols--+
|            |                           |           |
| file       |     your code             | imenu /   |
| tree       |     (with LSP, tree-sitter| lsp       |
|            |      syntax highlighting) | symbols   |
| C-c t      |                           | C-c i     |
|            |                           |           |
+            +---------------------------+           +
|            |     terminal (vterm)       |           |
|            |     C-c v                  |           |
+------------+---------------------------+-----------+
              [doom-modeline: file, git, lsp, clock]
```

This layout opens automatically when you switch projects with `C-c p p`.

## Cross-Platform Shortcuts (Cmd+C/V/X/Z)

Standard Cmd shortcuts work identically on both macOS and Linux:

| Shortcut | Action | How it works |
|----------|--------|-------------|
| `Cmd+C` | Copy | macOS: `s-c` binding. Linux: keyd translates to `C-c`, CUA mode copies when region active |
| `Cmd+V` | Paste | macOS: `s-v` binding. Linux: keyd translates to `C-v`, CUA mode pastes |
| `Cmd+X` | Cut | macOS: `s-x` binding. Linux: keyd translates to `C-x`, CUA mode cuts when region active |
| `Cmd+Z` | Undo | macOS: `s-z` binding. Linux: keyd translates to `C-z` (native undo) |
| `Cmd+Shift+Z` | Redo | macOS: `s-Z` binding. Linux: keyd translates to `C-S-z` |
| `Cmd+A` | Select all | macOS: `s-a` binding. Linux: keyd translates to `C-a` |
| `Cmd+S` | Save | macOS: `s-s` binding. Linux: keyd translates to `C-s` |
| `Cmd+F` | Find | macOS: `s-f` binding. Linux: keyd translates to `C-f` |
| `Cmd+W` | Close window | macOS: `s-w` binding. Linux: keyd translates to `C-w` |

**How CUA mode works:** On Linux, keyd translates `Cmd+C` → `Ctrl+C`. Since `C-c` is an Emacs prefix key (used by `C-c C-c`, `C-c l`, etc.), CUA mode makes it context-aware: with an active region it copies, without a region it starts the `C-c` prefix. Same for `C-x` (cut/prefix). Standard Emacs keybindings (`M-w`, `C-y`, `C-w`) still work alongside CUA.

**Note:** `C-v` (scroll up) is overridden by CUA paste. Use `PgDn` or mouse wheel to scroll down instead.

## IDE Mode (Coding)

This is the primary use case. The config provides a full IDE experience with LSP, tree-sitter, autocomplete, diagnostics, and AI assistants.

### Opening a Project

Press `C-c p p` (Projectile) to switch projects. **Do not use `C-x p p`** -- that's the built-in `project.el`, which doesn't trigger the IDE layout or workspace switching. This:
1. Creates/switches to a dedicated workspace (perspective)
2. Opens treemacs file tree on the left
3. Opens a terminal at the bottom
4. Prompts you to pick a file

Projects in `~/src/` are auto-discovered. Each project gets its own tab group, buffer set, and workspace that persists across restarts.

### Navigating Code

**Finding files and text:**

| Key | What it does | VS Code equivalent |
|-----|-------------|-------------------|
| `C-c p f` | Find file in project | Ctrl+P |
| `M-s g` | Search across project (ripgrep) | Ctrl+Shift+F |
| `C-s` | Search in current buffer | Ctrl+F |
| `C-x b` | Switch buffer | Recent tabs |
| `C-x C-r` | Recent files | Ctrl+R (recent) |
| `M-s f` | Find file by name (any directory) | - |

**Going to symbols and definitions:**

| Key | What it does | VS Code equivalent |
|-----|-------------|-------------------|
| `M-.` | Go to definition (peek) | F12 |
| `M-?` | Find all references (peek) | Shift+F12 |
| `M-g i` | Go to symbol in file (fuzzy) | Ctrl+Shift+O |
| `C-c l s` | Go to symbol in project (fuzzy) | Ctrl+T |
| `M-g g` | Go to line number | Ctrl+G |

**Sidebar panels:**

| Key | Panel | Side |
|-----|-------|------|
| `C-c t` | File tree (treemacs) | Left |
| `C-c i` | Symbol outline (imenu) | Right |
| `C-c l S` | LSP symbol tree (richer) | Right |
| `C-c l e` | Problems / errors list | Right |
| `C-c m` | Minimap | Right |

### Editing Code

**Autocomplete** pops up automatically after 1 character. Use `C-n`/`C-p` to navigate, `TAB` to insert, `C-g` to dismiss. Documentation appears inline after 0.5s.

**Multi-cursor editing:**

| Key | What it does | VS Code equivalent |
|-----|-------------|-------------------|
| `C-M-n` | Add cursor at next match | Ctrl+D |
| `C-M-p` | Add cursor at previous match | Ctrl+Shift+D |
| `C-c d` | Select all matches | Ctrl+Shift+L |
| `C-S-<click>` | Add cursor at click | Ctrl+Shift+Click |

**Refactoring (requires LSP):**

| Key | What it does |
|-----|-------------|
| `C-c l r r` | Rename symbol (project-wide) |
| `C-c l a a` | Code actions / quick fix |
| `C-c l = =` | Format buffer |

**Find & replace across files:**

1. `M-s g` -- search with ripgrep
2. `C-.` then `E` -- export results to an editable buffer
3. `C-c C-p` -- enable editing
4. Make your changes directly in the buffer
5. `C-c C-c` -- save all modified files

**Undo/Redo:** `Cmd+Z` undoes, `Cmd+Shift+Z` redoes. For the full visual undo tree, press `C-x u` — navigate branches with arrow keys, press `q` to close.

### Diagnostics

Errors and warnings appear automatically in the left fringe and as sideline annotations. LSP formats on save.

| Key | What it does |
|-----|-------------|
| `C-c l e` | Open problems panel (project-wide errors) |
| `C-c l D` | Browse diagnostics with fuzzy filter |
| `C-c l d` | Show hover documentation for symbol at point |

### Terminal

| Key | What it does |
|-----|-------------|
| `C-c v` or `C-\`` | Toggle terminal panel (show/hide) |
| `C-c V` | Maximize terminal to full frame / restore |

The terminal is a real shell (zsh via vterm). When maximized, pressing `C-c V` again restores your previous window layout exactly.

### Git

| Key | What it does |
|-----|-------------|
| `C-c g` | Open Magit (full git UI -- staging, committing, pushing, rebasing) |
| `C-c b` | Toggle inline blame (who changed each line, when, why) |

**Git gutter** indicators (green/red/blue bars) show in the left fringe automatically.

**Making a commit with conventional commits:**

1. `C-c g` -- open Magit
2. `s` -- stage files
3. `c c` -- start commit
4. `C-c C-t` -- open conventional commit menu, pick type (feat/fix/docs/...)
5. Type your message, then `C-c C-c` to finish

### AI Assistants

Three AI tools are available, each for different workflows:

**ECA (inline AI):**

| Key | What it does |
|-----|-------------|
| `C-c RET` | Send selected code or prompt to LLM |
| `C-c C-RET` | Open AI chat buffer |
| `C-c M-RET` | AI options menu (model, agent, mode) |

ECA provides Copilot-style inline completions, code rewriting (select code, describe changes, review diff), and chat.

**Claude Code (autonomous agent):**

| Key | What it does |
|-----|-------------|
| `C-c C` | Toggle Claude Code panel (show/hide) |
| `C-c C-'` | Claude Code menu |

Claude Code runs as a terminal agent with MCP integration -- it can read your files, see diagnostics, navigate symbols, and understand tree-sitter structure directly from Emacs.

**Codex:**

| Key | What it does |
|-----|-------------|
| `C-c X` | Launch Codex in project root |

### Code TODOs

TODO, FIXME, HACK, BUG, and NOTE comments are automatically highlighted in Dracula colors. You can search and track them:

| Key | What it does |
|-----|-------------|
| `C-c n` / `C-c N` | Jump to next/previous TODO comment |
| `M-s t` | Fuzzy search TODOs in current buffer |
| `M-s T` | Fuzzy search TODOs across entire project |
| `C-c o` | Capture the TODO at point into org-mode with a backlink |

See the "Bridging Code and Org" section below for the full workflow.

### Tabs

Tabs work like VS Code -- one tab per open file, grouped by project.

| Key | What it does |
|-----|-------------|
| `Ctrl+PageUp` | Previous tab |
| `Ctrl+PageDown` | Next tab |

Terminal, sidebar, and internal buffers are hidden from the tab bar.

### Workspaces

Each project gets its own workspace (perspective) with isolated buffers and layout.

| Key | What it does |
|-----|-------------|
| `C-c w s` | Switch workspace |
| `C-c w l` | List workspaces |
| `C-c w k` | Close workspace |

Workspaces auto-save on exit and restore on startup.

## Writing Mode (Prose, Blog Posts, Long-Form)

This config includes a full writing toolkit for everything from quick blog posts to book-length projects.

### Entering Writing Mode

Press **`C-c Z`** to toggle writing mode. This:

1. Saves your current window layout
2. Closes all sidebars (treemacs, terminal, symbols)
3. Centers the text (olivetti)
4. Enables typewriter scrolling (cursor stays at screen center)
5. Shows word count in the modeline

Press `C-c Z` again to restore your previous layout.

For lighter-weight options, toggle individual features:

| Key | What it does |
|-----|-------------|
| `C-c Z` | Full writing mode (toggle) |
| `C-c z` | Just center text (olivetti only) |
| `C-c -` | Just typewriter scrolling |

### Word Count & Goals

Word count shows automatically in the modeline for org files: `[247 words]`

Set a daily goal with `C-c W`:

```
C-c W → "Word count goal: " → 1000 → modeline shows: [247/1000 words]
```

### Section Focus (Logos)

For long documents, focus on one section at a time:

| Key | What it does |
|-----|-------------|
| `C-c {` | Toggle focus mode (narrows to current heading) |
| `C-c ]` | Step to next section |
| `C-c [` | Step to previous section |

In focus mode, each org heading becomes a "page". You see only the current section, centered on screen. Step through with `]`/`[`. Great for editing one chapter at a time without getting overwhelmed by the full document.

### Thesaurus & Dictionary

Look up words without leaving Emacs:

| Key | What it does |
|-----|-------------|
| `C-c y t` | Synonyms for word at point |
| `C-c y a` | Antonyms for word at point |
| `C-c y d` | Definitions (powerthesaurus) |
| `C-c y w` | Dictionary definition |
| `C-c y W` | Dictionary lookup (prompt for word) |

### Spell & Grammar Checking

Jinx runs automatically in all buffers. Misspelled words are underlined.

| Key | What it does |
|-----|-------------|
| `M-$` | Correct word at point (shows suggestions) |
| `C-M-$` | Switch spell-check language |

`ltex-ls-plus` provides grammar and style checking for markdown and org files via LSP. Errors appear as diagnostics (same as code errors).

### Exporting Your Writing

Export from any org buffer with `C-c C-e`, then pick a format:

| Keys | Format | Output |
|------|--------|--------|
| `C-c C-e l p` | PDF | Org → LaTeX → PDF (for manuscripts, print) |
| `C-c C-e p e` | EPUB | Org → pandoc → EPUB (for e-readers) |
| `C-c C-e p x` | DOCX | Org → pandoc → Word (for collaboration) |
| `C-c C-e h h` | HTML | Org → HTML (for web) |
| `C-c C-e H H` | Hugo | Org → Hugo markdown (for blog) |

### Reading EPUBs

Open any `.epub` file in Emacs -- it renders with olivetti and visual-line-mode automatically. Navigate with standard keys.

### Blog Post Workflow (Hugo)

Write blog posts in org-mode, export to Hugo:

1. **`C-c c b`** -- capture a new blog post (creates a dated entry with Hugo front matter)
2. Write your post as normal org content
3. **`C-c C-e H H`** -- export to Hugo-compatible markdown in `~/blog/`
4. Run `hugo serve` in the terminal (`C-c v`) to preview

Posts live as subtrees in `~/blog/content-org/posts.org`. Each post has PROPERTIES for Hugo metadata:

```org
* TODO My Post Title :blog:
:PROPERTIES:
:EXPORT_FILE_NAME: 2026-03-15-my-post-title
:EXPORT_HUGO_BUNDLE:
:END:

Post content goes here. Use org formatting -- headings, lists,
code blocks, links -- and ox-hugo converts it all.
```

Change the TODO to DONE when published.

### Long-Form Writing Workflow (Books, Essays)

For longer projects, use org's outline structure:

```org
#+TITLE: My Book
#+AUTHOR: Bryan Clark
#+OPTIONS: toc:t num:t

* Part One
** Chapter 1: The Beginning
Content here...
** Chapter 2: The Middle
Content here...
* Part Two
** Chapter 3: The Turn
...
```

Workflow:
1. **Outline first**: create your structure as org headings
2. **Focus mode** (`C-c {`): write one chapter at a time
3. **Step through** (`C-c ]`/`C-c [`): review chapter by chapter
4. **Set daily goals** (`C-c W`): track word count progress
5. **Use AI** (`C-c RET` or `C-c C`): ask for feedback, brainstorm, rewrite sections
6. **Export** (`C-c C-e`): produce PDF, EPUB, or DOCX when ready

### Markdown

Markdown files get syntax highlighting, LSP (marksman) provides heading navigation and link completion, and pandoc handles preview/export.

## Org Mode (Task & Knowledge Management)

Org-mode is a structured note-taking and task management system built into Emacs. Think of it as a plaintext combination of Notion + Todoist + time tracker.

### Quick Start

Your org files live in `~/Documents/org/`:

```
~/Documents/org/
  todo.org        -- tasks inbox + code TODOs
  journal.org     -- daily journal (auto-dated)
  habits.org      -- recurring habits
  birthdays.org   -- date tracking
  archive.org     -- completed items
  projects/       -- per-project task files (auto-created)
```

### Capturing Tasks

From **any buffer** (code, terminal, browser), press `C-c c` to capture. A popup shows template options:

| Keys | Template | What it captures |
|------|----------|-----------------|
| `t t` | Task | General TODO (goes to inbox) |
| `c t` | Code TODO | Task with file:line link + code block |
| `c b` | Bug | Bug report with file:line link |
| `c f` | FIXME | Instant capture of FIXME at cursor (no prompt) |
| `c p` | Project TODO | Task filed into current project's org file |
| `b` | Blog post | New Hugo blog post with front matter |
| `j j` | Journal | Timestamped journal entry (auto-clocks in) |
| `j m` | Meeting | Meeting notes with link to what you were looking at |

After typing your note, press `C-c C-c` to save or `C-c C-k` to cancel.

### Viewing Your Tasks (Agenda)

Press `C-c a` to open the agenda dispatcher, then choose a view:

| Key | View | Shows |
|-----|------|-------|
| `d` | Dashboard | This week's agenda + next actions + active projects |
| `n` | Next Tasks | Everything marked NEXT |
| `c` | Code Tasks | All TODOs/bugs captured from code |
| `p` | Project Tasks | Tasks from per-project org files |
| `w` | Workflow | Items grouped by state (waiting/review/planning/etc.) |
| `e` | Low Effort | Quick wins (< 15 min effort) |

In the agenda view, press `RET` on any item to jump to it. If it was captured from code, the link takes you straight to the file and line.

### Task States

Tasks flow through states. Press `C-S-<left>`/`C-S-<right>` on a heading to cycle:

**Simple tasks:** `TODO` -> `NEXT` -> `DONE`

**Project workflow:** `BACKLOG` -> `PLAN` -> `READY` -> `ACTIVE` -> `REVIEW` -> `WAIT`/`HOLD` -> `COMPLETED`/`CANC`

### Time Tracking

Clock in to track how long you spend on tasks. The current task and elapsed time show in the modeline.

| Key | What it does |
|-----|-------------|
| `C-c C-x C-i` | Clock in to last task (works from any buffer) |
| `C-c C-x C-o` | Clock out |
| `C-c C-x C-j` | Jump to the task you're currently clocked into |

Clock data persists across Emacs restarts. Journal and meeting captures auto-clock-in.

### Bridging Code and Org

This is where the IDE and org-mode connect. The workflow:

1. **While coding**, you see a `TODO` or `FIXME` comment that needs tracking
2. **`C-c o`** on that line -- instantly creates an org task with:
   - The comment text
   - A link back to the exact file and line
   - `:code:` and `:fixme:` tags for filtering
3. **`C-c a c`** -- view all code tasks in the agenda
4. **Click the link** in the org entry -- jumps back to the code
5. **`M-s T`** -- search all TODO/FIXME/HACK comments across the project (without org, just the code comments themselves)

For per-project tracking, use `C-c c cp` to capture into `~/Documents/org/projects/<project-name>.org`. These files are auto-included in the agenda.

### Journal

Press `C-c j` from anywhere for a quick journal entry. Entries are organized by date in `journal.org` and auto-clock-in (so you can track time spent journaling/reflecting).

## Tips & Tricks

### Discovering Keybindings

- **`C-c` then wait** -- which-key shows all available `C-c` bindings
- **`C-c l` then wait** -- shows all LSP commands
- **`C-c p` then wait** -- shows all Projectile project commands (use these, not `C-x p` which is built-in `project.el`)
- **`C-h B`** -- searchable list of all keybindings
- **`C-h k` then press a key** -- describes what that key does

### Fuzzy Finding Everything

Nearly every prompt uses orderless matching. Type space-separated terms in any order:

- `init el` matches `init.el`
- `py test` matches `test_parser.py`
- `def main` in symbol search matches `defun main-loop`

### Nix Dev Shell Integration

When you open a file in a project with `flake.nix` + `.envrc`, Emacs automatically loads that project's dev shell environment (via `envrc`). LSP servers and tools from the dev shell are available without any extra configuration.

### VS Code Compatibility

This config is designed to work alongside VS Code with the [emacs-mcx](https://github.com/whitphx/vscode-emacs-mcx) extension. Standard Emacs navigation (C-f/b/n/p, C-a/e, C-k, C-w/M-w/C-y, C-x C-s) and code navigation (M-., M-?, C-M-n/p) work identically in both editors. All custom bindings use the `C-c` prefix, which emacs-mcx leaves free.

`Cmd+C/V/X/Z` work in VS Code on both platforms: on macOS they're native, on Linux keyd translates `Super+key` → `Ctrl+key`. emacs-mcx only remaps navigation keys (`C-a/e/k/n/p/f/b`), not `C-c/v/x/z`, so there's no conflict.

### Getting Unstuck

- **`ESC`** or **`C-g`** -- cancel whatever is happening
- **`C-x u`** -- visual undo (see all undo branches, navigate with arrows)
- **`C-/`** -- quick undo (one step back)
- **`C-x 1`** -- close all windows except current (reset layout)
- **`M-x bc/project-layout`** -- reset to the standard IDE layout
- **`C-h k`** then press any key -- find out what it does
