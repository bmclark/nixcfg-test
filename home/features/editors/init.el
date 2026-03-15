;;; init.el --- Bryan Clark's Emacs configuration -*- lexical-binding: t; -*-

;; Prevent Emacs from writing customizations to ~/.emacs (which shadows init.el)
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file)
  (load custom-file))

;;; UI defaults
(setq inhibit-startup-message t)
(scroll-bar-mode -1)
(tool-bar-mode -1)
(tooltip-mode -1)
(set-fringe-mode 10)
(global-display-line-numbers-mode t)
(column-number-mode)
(menu-bar-mode -1)
(setq visible-bell t)

;; Font — matches Ghostty/terminal config
(set-face-attribute 'default nil :font "JetBrainsMono Nerd Font" :height 120)

;; Make ESC quit prompts
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

;; Transparency
(set-frame-parameter nil 'alpha-background 90)
(add-to-list 'default-frame-alist '(alpha-background . 90))

;; Whitespace cleanup on save
(add-hook 'before-save-hook 'delete-trailing-whitespace)
(setq require-final-newline t)

;; Tabs / indentation defaults
(setq-default indent-tabs-mode nil)
(setq-default tab-width 2)

;; Auto-revert files changed on disk
(global-auto-revert-mode 1)

;; Save backup/autosave files out of the way, mirroring the original directory structure.
;; e.g. ~/src/foo/bar.py~ → ~/.emacs.d/backups/~/src/foo/bar.py~
(defun bc/backup-file-name (fpath)
  "Mirror FPATH's directory structure under ~/.emacs.d/backups/."
  (let* ((backup-root (expand-file-name "backups" user-emacs-directory))
         (backup-path (expand-file-name (substring fpath 1) backup-root)))
    (make-directory (file-name-directory backup-path) t)
    backup-path))
(setq make-backup-file-name-function #'bc/backup-file-name)
(setq auto-save-file-name-transforms `((".*" ,(expand-file-name "autosaves/" user-emacs-directory) t)))
(make-directory (expand-file-name "autosaves" user-emacs-directory) t)

;; Show matching parens instantly
(setq show-paren-delay 0)
(show-paren-mode 1)

;; Smooth scrolling
(setq scroll-margin 3
      scroll-conservatively 101
      scroll-preserve-screen-position t)

;; Built-in quality-of-life modes
(recentf-mode 1)                        ; track recently opened files
(savehist-mode 1)                       ; persist minibuffer history across sessions
(save-place-mode 1)                     ; remember cursor position in files
(electric-pair-mode 1)                  ; auto-close parens, brackets, quotes

;; Built-in since Emacs 30
(which-key-mode)
(setq which-key-idle-delay 0.5)
(editorconfig-mode 1)

;;; Package management via MELPA
(require 'package)
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("gnu" . "https://elpa.gnu.org/packages/")
                         ("nongnu" . "https://elpa.nongnu.org/nongnu/")))
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

;; use-package is built-in since Emacs 29
(require 'use-package)
(setq use-package-always-ensure t)

;;; Tree-sitter — auto-remap to *-ts-mode when grammars are available
;; Installed via Nix (treesit-grammars.with-all-grammars + treesit-auto).
(use-package treesit-auto
  :ensure nil
  :demand t
  :custom (treesit-auto-install nil) ; grammars come from Nix, not downloaded
  :config (global-treesit-auto-mode))

;;; Theme — Dracula
(use-package dracula-theme
  :init (load-theme 'dracula t))

(use-package doom-modeline
  :init (doom-modeline-mode 1)
  :custom ((doom-modeline-height 15)))

;;; Buffer tabs — centaur-tabs (VS Code-style tab bar)
(use-package centaur-tabs
  :hook (after-init . centaur-tabs-mode)
  :custom
  (centaur-tabs-style "bar")
  (centaur-tabs-set-bar 'under)
  (centaur-tabs-set-icons t)
  (centaur-tabs-icon-type 'nerd-icons)
  (centaur-tabs-set-modified-marker t)
  (centaur-tabs-modified-marker "●")
  (centaur-tabs-height 32)
  (centaur-tabs-gray-out-icons 'buffer)
  :bind
  (("C-<prior>" . centaur-tabs-backward)      ; Ctrl+PageUp  — prev tab
   ("C-<next>" . centaur-tabs-forward))        ; Ctrl+PageDown — next tab
  :config
  (centaur-tabs-group-by-projectile-project)
  ;; Hide tabs for non-editor buffers (terminals, sidebars, internal)
  (setq centaur-tabs-excluded-prefixes
        '("*Messages" "*scratch" "*Help" "*Completions" " *"
          "*Treemacs" "*vterm" "*magit" "*lsp" "*flycheck")))

;;; Completion — Vertico / Consult / Orderless / Marginalia / Embark
;; Modern completing-read stack: native Emacs API, composable, fast.

;; Vertico — vertical completion UI (like VS Code command palette)
(use-package vertico
  :init (vertico-mode)
  :custom
  (vertico-cycle t)
  (vertico-count 15)
  :bind (:map vertico-map
         ("C-j" . vertico-next)
         ("C-k" . vertico-previous)
         ("C-l" . vertico-insert)))

;; Orderless — flexible matching (space-separated terms, regex, initials)
(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles partial-completion)))))

;; Marginalia — rich annotations in minibuffer (file sizes, docstrings, etc.)
(use-package marginalia
  :init (marginalia-mode))

;; Consult — enhanced search/navigation commands (replaces Counsel/Swiper)
(use-package consult
  :bind (("C-s" . consult-line)               ; search in buffer (was swiper)
         ("M-s g" . consult-ripgrep)           ; project-wide search (like VS Code Ctrl+Shift+F)
         ("M-s l" . consult-line)              ; search lines
         ("M-s f" . consult-find)              ; find file by name
         ("C-x b" . consult-buffer)            ; switch buffer (was counsel-switch-buffer)
         ("C-x C-r" . consult-recent-file)     ; recent files (was counsel-recentf)
         ("M-g g" . consult-goto-line)         ; go to line
         ("M-g i" . consult-imenu)             ; symbol navigation (like VS Code Ctrl+Shift+O)
         ("M-g M-g" . consult-goto-line)
         ("M-y" . consult-yank-pop)            ; paste from kill ring (like VS Code clipboard history)
         ("C-x p b" . consult-project-buffer)) ; project buffers
  :config
  (consult-customize
   consult-ripgrep consult-grep consult-buffer
   :preview-key "M-."))                        ; manual preview with M-.

;; Embark — contextual actions on any completion candidate (like right-click menu)
(use-package embark
  :bind (("C-." . embark-act)                  ; act on target at point
         ("C-;" . embark-dwim)                 ; do the default action
         ("C-h B" . embark-bindings))          ; show all bindings
  :config
  (setq prefix-help-command #'embark-prefix-help-command))

(use-package embark-consult
  :after (embark consult)
  :hook (embark-collect-mode . consult-preview-at-point-mode))

;; Helpful — better *help* buffers
(use-package helpful
  :bind
  ([remap describe-function] . helpful-callable)
  ([remap describe-command] . helpful-command)
  ([remap describe-variable] . helpful-variable)
  ([remap describe-key] . helpful-key))

;;; Navigation / Utilities
(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

;; Highlight TODO/FIXME/HACK/NOTE in code comments (like VS Code Todo Highlight)
(use-package hl-todo
  :hook (prog-mode . hl-todo-mode)
  :bind (:map hl-todo-mode-map
         ("C-c n" . hl-todo-next)               ; jump to next TODO/FIXME
         ("C-c N" . hl-todo-previous))           ; jump to previous
  :custom
  (hl-todo-keyword-faces
   '(("TODO"  . "#ffb86c")
     ("FIXME" . "#ff5555")
     ("HACK"  . "#ff79c6")
     ("NOTE"  . "#8be9fd")
     ("BUG"   . "#ff5555")
     ("XXX"   . "#ff79c6"))))

;; Consult + hl-todo — search all TODO/FIXME/HACK across the project
(use-package consult-todo
  :after (consult hl-todo)
  :bind (("M-s t" . consult-todo)                ; search TODOs in current buffer
         ("M-s T" . consult-todo-all))            ; search TODOs across project
  :custom (consult-todo-narrow
           '((?t . "TODO")
             (?f . "FIXME")
             (?h . "HACK")
             (?b . "BUG")
             (?n . "NOTE"))))

;; Capture code TODO/FIXME at point into org (bridge hl-todo → org-capture)
(defun bc/capture-todo-at-point ()
  "Capture the TODO/FIXME comment at point into org via the 'cf' template."
  (interactive)
  (let ((thing (thing-at-point 'line t)))
    (when thing
      (set-text-properties 0 (length thing) nil thing)
      (let ((org-capture-initial (string-trim thing)))
        (org-capture nil "cf")))))
(global-set-key (kbd "C-c o") #'bc/capture-todo-at-point)

;; Indent guides — vertical lines showing indentation level (like VS Code)
(use-package highlight-indent-guides
  :hook (prog-mode . highlight-indent-guides-mode)
  :custom
  (highlight-indent-guides-method 'character)
  (highlight-indent-guides-responsive 'top))

;; Inline color preview for hex/rgb values (like VS Code color swatches)
(use-package rainbow-mode
  :hook (prog-mode . rainbow-mode))

;; Multi-cursor editing (matches emacs-mcx addSelectionToNext/PrevFindMatch)
(use-package multiple-cursors
  :bind (("C-M-n" . mc/mark-next-like-this)          ; next match (emacs-mcx C-M-n)
         ("C-M-p" . mc/mark-previous-like-this)      ; prev match (emacs-mcx C-M-p)
         ("C-c d" . mc/mark-all-like-this)           ; mark all matches
         ("C-S-<mouse-1>" . mc/add-cursor-on-click))) ; Ctrl+Shift+Click — add cursor

;; Visual undo tree — branching undo history (like VS Code timeline)
(use-package vundo
  :bind ("C-x u" . vundo)
  :custom (vundo-glyph-alist vundo-unicode-symbols))

;; Zen/focus mode — centered, distraction-free editing
(use-package olivetti
  :bind ("C-c z" . olivetti-mode)
  :custom (olivetti-body-width 100))

;; Editable grep results — project-wide find & replace (like VS Code search+replace)
(use-package wgrep
  :custom (wgrep-auto-save-buffer t))

;; Minimap — scroll overview sidebar (like VS Code minimap)
(use-package minimap
  :bind ("C-c m" . minimap-mode)
  :custom
  (minimap-window-location 'right)
  (minimap-width-fraction 0.08)
  (minimap-minimum-width 15))

(use-package nerd-icons)

;; Icons in completion UI (minibuffer + corfu)
(use-package nerd-icons-completion
  :after marginalia
  :config (nerd-icons-completion-mode)
  :hook (marginalia-mode . nerd-icons-completion-marginalia-setup))

(use-package nerd-icons-corfu
  :after corfu
  :config (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter))

;;; ============================================================
;;; IDE: LSP, Completion, Diagnostics, Snippets, Treemacs
;;; ============================================================

;;; Corfu — in-buffer completion popup (like VS Code autocomplete)
(use-package corfu
  :init (global-corfu-mode)
  :custom
  (corfu-auto t)                           ; auto-popup (like VS Code)
  (corfu-auto-prefix 1)                    ; show after 1 char
  (corfu-auto-delay 0.1)                   ; 100ms delay
  (corfu-cycle t)                          ; wrap around
  (corfu-preselect 'prompt)                ; don't auto-select first
  (corfu-popupinfo-delay '(0.5 . 0.2))    ; doc popup delay
  :bind (:map corfu-map
         ("C-n" . corfu-next)
         ("C-p" . corfu-previous)
         ("TAB" . corfu-insert)
         ("<tab>" . corfu-insert)
         ("C-g" . corfu-quit))
  :config
  (corfu-popupinfo-mode 1))               ; show docs inline (like VS Code)

;; Cape — extra completion sources (file paths, dabbrev, keywords, etc.)
(use-package cape
  :init
  (add-hook 'completion-at-point-functions #'cape-dabbrev)
  (add-hook 'completion-at-point-functions #'cape-file)
  (add-hook 'completion-at-point-functions #'cape-elisp-block))

;;; Flycheck — inline diagnostics (like VS Code Error Lens)
(use-package flycheck
  :hook (after-init . global-flycheck-mode)
  :custom
  (flycheck-indication-mode 'left-fringe)
  (flycheck-check-syntax-automatically '(save mode-enabled)))

;;; YASnippet — snippet expansion
(use-package yasnippet
  :hook (after-init . yas-global-mode))

(use-package yasnippet-snippets
  :after yasnippet)

;;; LSP Mode — language server protocol client
(use-package lsp-mode
  :commands (lsp lsp-deferred)
  :hook ((python-mode . lsp-deferred)
         (python-ts-mode . lsp-deferred)
         (js-mode . lsp-deferred)
         (js-ts-mode . lsp-deferred)
         (typescript-mode . lsp-deferred)
         (typescript-ts-mode . lsp-deferred)
         (tsx-ts-mode . lsp-deferred)
         (web-mode . lsp-deferred)
         (yaml-mode . lsp-deferred)
         (yaml-ts-mode . lsp-deferred)
         (dockerfile-mode . lsp-deferred)
         (dockerfile-ts-mode . lsp-deferred)
         (terraform-mode . lsp-deferred)
         (sh-mode . lsp-deferred)
         (bash-ts-mode . lsp-deferred)
         (nix-mode . lsp-deferred)
         (go-mode . lsp-deferred)
         (go-ts-mode . lsp-deferred)
         (rust-mode . lsp-deferred)
         (rust-ts-mode . lsp-deferred))
  :bind-keymap ("C-c l" . lsp-command-map)
  :custom
  (lsp-keymap-prefix "C-c l")
  ;; Performance tuning
  (lsp-idle-delay 0.3)
  (lsp-log-io nil)
  (lsp-completion-provider :capf)
  (lsp-headerline-breadcrumb-enable t)
  ;; Format on save (like VS Code)
  (lsp-enable-on-type-formatting nil)
  ;; Nix: nil language server + alejandra formatter
  (lsp-nix-nil-formatter ["alejandra"])
  :config
  ;; Format and organize imports on save
  (add-hook 'before-save-hook
            (lambda ()
              (when (bound-and-true-p lsp-mode)
                (lsp-format-buffer)
                (when (derived-mode-p 'python-mode 'python-ts-mode
                                      'go-mode 'go-ts-mode
                                      'rust-mode 'rust-ts-mode)
                  (lsp-organize-imports))))))

;;; LSP UI — inline hints, peek, sideline diagnostics
(use-package lsp-ui
  :after lsp-mode
  :custom
  (lsp-ui-doc-enable t)
  (lsp-ui-doc-position 'at-point)
  (lsp-ui-doc-delay 0.5)
  (lsp-ui-sideline-enable t)
  (lsp-ui-sideline-show-diagnostics t)
  (lsp-ui-sideline-show-hover nil)
  (lsp-ui-sideline-show-code-actions t)
  (lsp-ui-peek-enable t)
  :bind (:map lsp-mode-map
         ("M-." . lsp-ui-peek-find-definitions)
         ("M-?" . lsp-ui-peek-find-references)
         ("C-c l d" . lsp-ui-doc-show)))

;;; LSP + Consult integration
(use-package consult-lsp
  :after (lsp-mode consult)
  :bind (:map lsp-mode-map
         ("C-c l s" . consult-lsp-symbols)           ; fuzzy symbol search across project
         ("C-c l D" . consult-lsp-diagnostics)))

;;; LSP + Treemacs integration — symbol outline & error list
(use-package lsp-treemacs
  :after (lsp-mode treemacs)
  :bind (:map lsp-mode-map
         ("C-c l S" . lsp-treemacs-symbols)          ; symbol tree sidebar (Outline)
         ("C-c l h" . lsp-treemacs-call-hierarchy)    ; call hierarchy
         ("C-c l t" . lsp-treemacs-type-hierarchy)    ; type hierarchy
         ("C-c l e" . lsp-treemacs-errors-list))      ; project-wide errors
  :config
  (lsp-treemacs-sync-mode 1)
  ;; Open symbol/hierarchy panels on the right side
  (setq lsp-treemacs-symbols-position-params
        '((side . right) (slot . 0) (window-width . 35))))

;;; imenu-list — persistent symbol outline sidebar (works without LSP too)
(use-package imenu-list
  :bind ("C-c i" . imenu-list-smart-toggle)
  :custom
  (imenu-list-focus-after-activation t)
  (imenu-list-auto-resize t)
  (imenu-list-position 'right))

;;; Treemacs — file tree sidebar (like VS Code explorer)
(use-package treemacs
  :bind (("C-c t" . treemacs)
         ("C-c T" . treemacs-select-window))
  :custom
  (treemacs-width 30)
  (treemacs-is-never-other-window t)
  :config
  (treemacs-project-follow-mode t))

(use-package treemacs-projectile
  :after (treemacs projectile))

(use-package treemacs-magit
  :after (treemacs magit))

(use-package treemacs-nerd-icons
  :after (treemacs nerd-icons)
  :config (treemacs-load-theme "nerd-icons"))

;;; ============================================================
;;; Nix dev shell integration — direnv / envrc
;;; ============================================================

;; envrc: buffer-local direnv support, picks up nix develop / devShells
(use-package envrc
  :hook (after-init . envrc-global-mode))

;;; ============================================================
;;; Language modes
;;; ============================================================

;;; Nix
(use-package nix-mode
  :mode "\\.nix\\'")

;;; Terraform
(use-package terraform-mode
  :mode ("\\.tf\\'" "\\.tfvars\\'")
  :custom (terraform-indent-level 2))

;;; YAML
(use-package yaml-mode
  :mode ("\\.ya?ml\\'" "\\.yml\\'"))

;;; Dockerfile
(use-package dockerfile-mode
  :mode "Dockerfile\\'")

;;; Markdown
(use-package markdown-mode
  :mode ("\\.md\\'" "\\.markdown\\'")
  :custom (markdown-command "pandoc"))

;;; Web (JSX/TSX/HTML templates)
(use-package web-mode
  :mode ("\\.tsx\\'" "\\.jsx\\'" "\\.html\\'" "\\.hbs\\'")
  :custom
  (web-mode-markup-indent-offset 2)
  (web-mode-css-indent-offset 2)
  (web-mode-code-indent-offset 2))

;;; TypeScript
(use-package typescript-mode
  :mode "\\.ts\\'")

;;; Go
(use-package go-mode
  :mode "\\.go\\'")

;;; Rust
(use-package rust-mode
  :mode "\\.rs\\'")

;;; TOML
(use-package toml-mode
  :mode "\\.toml\\'")

;;; JSON — tree-sitter or built-in json-mode
(use-package json-mode
  :mode "\\.json\\'")

;;; Ansible — detect ansible yaml files
(use-package ansible
  :hook (yaml-mode . (lambda ()
                       (when (or (string-match-p "ansible" (or buffer-file-name ""))
                                 (string-match-p "playbook" (or buffer-file-name ""))
                                 (string-match-p "roles/" (or buffer-file-name "")))
                         (ansible 1)))))

;;; ============================================================
;;; Terminal — vterm
;;; ============================================================

;; vterm is installed via Nix (programs.emacs.extraPackages) with pre-compiled
;; native module. :ensure nil prevents use-package from trying MELPA.
(use-package vterm
  :ensure nil
  :demand t                                ; load eagerly so (vterm) is always available
  :bind (("C-c v" . bc/toggle-vterm)
         ("C-c V" . bc/maximize-vterm))
  :custom
  (vterm-max-scrollback 10000)
  (vterm-shell (or (executable-find "zsh") shell-file-name)))

(defvar bc/--vterm-prev-config nil
  "Window configuration saved before maximizing vterm.")

(defvar bc/--vterm-debug t
  "When non-nil, log vterm panel state transitions to *Messages*.")

(defvar bc/--vterm-panel-buffer nil
  "Live buffer object for the dedicated vterm panel, when available.")

(defvar bc/--vterm-panel-window nil
  "Live window object for the dedicated vterm panel, when visible.")

(defconst bc/--vterm-panel-name "*vterm-panel*"
  "Buffer name for the toggle-able vterm panel.")

(defun bc/--vterm-log (fmt &rest args)
  "Log a vterm debug message with FMT and ARGS when debugging is enabled."
  (when bc/--vterm-debug
    (apply #'message (concat "[bc/vterm] " fmt) args)))

(defun bc/--vterm-panel-buffer (&optional window)
  "Return the vterm panel buffer, creating it in WINDOW if needed.
Uses `get-buffer' (C-level, immune to perspective.el filtering)."
  (if (buffer-live-p bc/--vterm-panel-buffer)
      bc/--vterm-panel-buffer
    (let ((vterm-buffer-name bc/--vterm-panel-name))
      (setq bc/--vterm-panel-buffer
            (with-selected-window (or window (selected-window))
              (let ((buf (vterm)))
                (bc/--vterm-log "created panel buffer=%S selected=%S window=%S"
                                (buffer-name buf)
                                (buffer-name (current-buffer))
                                window)
                buf))))))

(defun bc/--live-vterm-panel-window ()
  "Return the live window displaying the dedicated vterm panel."
  (let ((win (cond
              ((and (window-live-p bc/--vterm-panel-window)
                    (eq (window-parameter bc/--vterm-panel-window 'bc-vterm-panel) t))
               bc/--vterm-panel-window)
              ((buffer-live-p bc/--vterm-panel-buffer)
               (seq-find
                (lambda (w)
                  (and (eq (window-buffer w) bc/--vterm-panel-buffer)
                       (eq (window-frame w) (selected-frame))))
                (window-list (selected-frame) 'nomini)))
              (t nil))))
    (setq bc/--vterm-panel-window win)
    win))

(defun bc/--show-vterm-panel ()
  "Show the vterm panel in a dedicated bottom side window."
  (let* ((origin (selected-window))
         (buf (bc/--vterm-panel-buffer))
         (win (display-buffer-in-side-window
               buf
               '((side . bottom)
                 (slot . 0)
                 (window-height . 0.33)))))
    ;; Keep other commands from reusing the terminal pane for file buffers.
    (set-window-dedicated-p win t)
    (set-window-parameter win 'bc-vterm-panel t)
    (set-window-parameter win 'no-delete-other-windows nil)
    (setq bc/--vterm-panel-window win)
    (bc/--vterm-log "show side window=%S buffer=%S selected=%S"
                    win
                    (buffer-name buf)
                    (buffer-name (window-buffer origin)))
    (select-window origin)
    (bc/--vterm-log "after show selected=%S panel-buffer=%S"
                    (buffer-name (window-buffer (selected-window)))
                    (buffer-name (window-buffer win)))
    win))

;; C-c v — toggle terminal panel at bottom (like VS Code Ctrl+`)
;;   hidden  → show at bottom third
;;   visible → hide
(defun bc/toggle-vterm ()
  "Toggle vterm panel at the bottom of the frame."
  (interactive)
  ;; If maximized, restore first
  (when bc/--vterm-prev-config
    (set-window-configuration bc/--vterm-prev-config)
    (setq bc/--vterm-prev-config nil))
  (if-let ((win (bc/--live-vterm-panel-window)))
      (progn
        (bc/--vterm-log "hide panel window=%S buffer=%S selected=%S"
                        win
                        (buffer-name (window-buffer win))
                        (buffer-name (window-buffer (selected-window))))
        (setq bc/--vterm-panel-window nil)
        (delete-window win))
    (bc/--show-vterm-panel)))

;; C-c V — maximize / restore terminal
(defun bc/maximize-vterm ()
  "Maximize vterm to full frame, or restore previous layout."
  (interactive)
  (if bc/--vterm-prev-config
      (progn
        (set-window-configuration bc/--vterm-prev-config)
        (setq bc/--vterm-prev-config nil))
    (setq bc/--vterm-prev-config (current-window-configuration))
    (delete-other-windows)
    (set-window-buffer (selected-window)
                       (bc/--vterm-panel-buffer (selected-window)))))

;;; ============================================================
;;; Project management — projectile + perspective.el
;;; ============================================================

;;; Default project IDE layout
(defun bc/project-layout ()
  "Set up VS Code-like IDE layout: treemacs | editor | vterm bottom."
  (interactive)
  (delete-other-windows)
  ;; Open treemacs for the project on the left
  (treemacs-add-and-display-current-project-exclusively)
  ;; Move back to the editor window (treemacs marks itself as not-other-window)
  (other-window 1)
  ;; Split a terminal at the bottom
  (let ((editor-win (selected-window)))
    (bc/--show-vterm-panel)
    ;; Return focus to editor and prompt for a file
    (select-window editor-win)
    (projectile-find-file)))

(use-package projectile
  :diminish projectile-mode
  :config (projectile-mode)
  :custom ((projectile-completion-system 'default))  ; uses vertico via completing-read
  :bind-keymap
  ("C-c p" . projectile-command-map)
  :init
  (when (file-directory-p "~/src")
    (setq projectile-project-search-path '("~/src")))
  (setq projectile-switch-project-action
        (lambda ()
          (persp-switch (projectile-project-name))
          (bc/project-layout))))

;;; Workspace persistence — perspective.el (per-project layout save/restore)
;; Each project gets its own perspective (buffer set + window layout).
;; Perspectives auto-save on exit and restore on startup.
;; C-c w s: switch  |  C-c w l: list  |  C-c w k: kill
(use-package perspective
  :custom
  (persp-state-default-file (expand-file-name "perspectives" user-emacs-directory))
  (persp-mode-prefix-key (kbd "C-c w"))
  :init (persp-mode)
  :config
  (add-hook 'emacs-startup-hook
            (lambda ()
              (when (file-exists-p persp-state-default-file)
                (persp-state-load persp-state-default-file))))
  (add-hook 'kill-emacs-hook #'persp-state-save))

;;; Git
(use-package magit
  :bind ("C-c g" . magit-status)
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

;;; Conventional Commits — transient menu in magit commit buffers
;; Press C-c C-t in a commit message buffer to pick type + optional scope.
(defvar bc/cc-types
  '("feat" "fix" "docs" "style" "refactor" "perf" "test" "build" "ci" "chore" "revert")
  "Conventional commit type prefixes.")

(defun bc/cc-insert (type)
  "Insert conventional commit TYPE prefix, prompting for optional scope."
  (let* ((scope (read-string (format "%s scope (empty for none): " type)))
         (prefix (if (string-empty-p scope)
                     (format "%s: " type)
                   (format "%s(%s): " type scope))))
    (goto-char (point-min))
    (insert prefix)))

(defun bc/cc-feat () "Insert feat: prefix." (interactive) (bc/cc-insert "feat"))
(defun bc/cc-fix () "Insert fix: prefix." (interactive) (bc/cc-insert "fix"))
(defun bc/cc-docs () "Insert docs: prefix." (interactive) (bc/cc-insert "docs"))
(defun bc/cc-style () "Insert style: prefix." (interactive) (bc/cc-insert "style"))
(defun bc/cc-refactor () "Insert refactor: prefix." (interactive) (bc/cc-insert "refactor"))
(defun bc/cc-perf () "Insert perf: prefix." (interactive) (bc/cc-insert "perf"))
(defun bc/cc-test () "Insert test: prefix." (interactive) (bc/cc-insert "test"))
(defun bc/cc-build () "Insert build: prefix." (interactive) (bc/cc-insert "build"))
(defun bc/cc-ci () "Insert ci: prefix." (interactive) (bc/cc-insert "ci"))
(defun bc/cc-chore () "Insert chore: prefix." (interactive) (bc/cc-insert "chore"))
(defun bc/cc-revert () "Insert revert: prefix." (interactive) (bc/cc-insert "revert"))
(defun bc/cc-breaking () "Add BREAKING CHANGE footer." (interactive)
  (goto-char (point-max))
  (unless (bolp) (insert "\n"))
  (insert "\nBREAKING CHANGE: "))

(with-eval-after-load 'transient
  (transient-define-prefix bc/cc-menu ()
    "Conventional Commits prefix menu."
    ["Type"
     ["Common"
      ("f" "feat      — new feature" bc/cc-feat)
      ("x" "fix       — bug fix" bc/cc-fix)
      ("d" "docs      — documentation" bc/cc-docs)
      ("r" "refactor  — restructure code" bc/cc-refactor)
      ("t" "test      — add/fix tests" bc/cc-test)]
     ["Other"
      ("p" "perf      — performance" bc/cc-perf)
      ("s" "style     — formatting" bc/cc-style)
      ("b" "build     — build system" bc/cc-build)
      ("i" "ci        — CI/CD" bc/cc-ci)
      ("c" "chore     — maintenance" bc/cc-chore)
      ("v" "revert    — revert commit" bc/cc-revert)]
     ["Extras"
      ("!" "BREAKING CHANGE footer" bc/cc-breaking)]]))

(with-eval-after-load 'git-commit
  (define-key git-commit-mode-map (kbd "C-c C-t") #'bc/cc-menu))

;; Show git diff in the gutter (like VS Code gutter indicators)
(use-package diff-hl
  :hook ((after-init . global-diff-hl-mode)
         (magit-pre-refresh . diff-hl-magit-pre-refresh)
         (magit-post-refresh . diff-hl-magit-post-refresh))
  :custom (diff-hl-draw-borders nil))

;; Inline git blame — show who changed each line (like VS Code GitLens)
(use-package blamer
  :bind ("C-c b" . blamer-mode)
  :custom
  (blamer-idle-time 0.5)
  (blamer-min-offset 40)
  (blamer-type 'visual)
  (blamer-prettify-time-p t))

;;; ============================================================
;;; Org Mode
;;; ============================================================

(setq org-agenda-files
      '("~/Documents/org/todo.org"
        "~/Documents/org/habits.org"
        "~/Documents/org/birthdays.org"))
;; Also scan per-project org files for agenda
(when (file-directory-p "~/Documents/org/projects")
  (setq org-agenda-files
        (append org-agenda-files
                (file-expand-wildcards "~/Documents/org/projects/*.org"))))

(global-set-key (kbd "C-c a") #'org-agenda)
(global-set-key (kbd "C-c c") #'org-capture)

;; Clock — quick time tracking from anywhere
(global-set-key (kbd "C-c C-x C-i") #'org-clock-in-last)
(global-set-key (kbd "C-c C-x C-o") #'org-clock-out)
(global-set-key (kbd "C-c C-x C-j") #'org-clock-goto)

(defun efs/org-mode-setup ()
  (org-indent-mode)
  (variable-pitch-mode 1)
  (visual-line-mode 1))

(defun efs/org-font-setup ()
  (font-lock-add-keywords 'org-mode
                          '(("^ *\\([-]\\) "
                             (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))
  (dolist (face '((org-level-1 . 1.2)
                  (org-level-2 . 1.1)
                  (org-level-3 . 1.05)
                  (org-level-4 . 1.0)
                  (org-level-5 . 1.1)
                  (org-level-6 . 1.1)
                  (org-level-7 . 1.1)
                  (org-level-8 . 1.1)))
    (set-face-attribute (car face) nil :font "JetBrainsMono Nerd Font" :weight 'regular :height (cdr face)))
  (set-face-attribute 'org-block nil :foreground nil :inherit 'fixed-pitch)
  (set-face-attribute 'org-code nil   :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-table nil   :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-verbatim nil :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-special-keyword nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-meta-line nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-checkbox nil :inherit 'fixed-pitch))

(use-package org
  :commands (org-capture org-agenda)
  :hook (org-mode . efs/org-mode-setup)
  :config
  (setq org-ellipsis " ▾")
  (setq org-agenda-start-with-log-mode t)
  (setq org-log-done 'time)
  (setq org-log-into-drawer t)

  ;; Clock: show in modeline, persist across sessions
  (setq org-clock-persist 'history)
  (org-clock-persistence-insinuate)
  (setq org-clock-in-resume t)
  (setq org-clock-out-remove-zero-time-clocks t)

  (require 'org-habit)
  (add-to-list 'org-modules 'org-habit)
  (setq org-habit-graph-column 60)

  (setq org-todo-keywords
    '((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d!)")
      (sequence "BACKLOG(b)" "PLAN(p)" "READY(r)" "ACTIVE(a)" "REVIEW(v)" "WAIT(w@/!)" "HOLD(h)" "|" "COMPLETED(c)" "CANC(k@)")))

  (setq org-refile-targets
    '(("archive.org" :maxlevel . 1)
      ("todo.org" :maxlevel . 1)))

  (advice-add 'org-refile :after 'org-save-all-org-buffers)

  (setq org-tag-alist
    '((:startgroup)
       (:endgroup)
       ("@errand" . ?E)
       ("@home" . ?H)
       ("@work" . ?W)
       ("agenda" . ?a)
       ("planning" . ?p)
       ("publish" . ?P)
       ("batch" . ?b)
       ("note" . ?n)
       ("idea" . ?i)))

  (setq org-agenda-custom-commands
   '(("d" "Dashboard"
     ((agenda "" ((org-deadline-warning-days 7)))
      (todo "NEXT"
        ((org-agenda-overriding-header "Next Tasks")))
      (tags-todo "agenda/ACTIVE" ((org-agenda-overriding-header "Active Projects")))))

    ("n" "Next Tasks"
     ((todo "NEXT"
        ((org-agenda-overriding-header "Next Tasks")))))

    ("W" "Work Tasks" tags-todo "+work-email")

    ("e" tags-todo "+TODO=\"NEXT\"+Effort<15&+Effort>0"
     ((org-agenda-overriding-header "Low Effort Tasks")
      (org-agenda-max-todos 20)
      (org-agenda-files org-agenda-files)))

    ("c" "Code Tasks" tags-todo "+code"
     ((org-agenda-overriding-header "Code TODOs / Bugs / FIXMEs")))

    ("p" "Project Tasks"
     ((tags-todo "+code"
        ((org-agenda-overriding-header "Code Tasks")
         (org-agenda-files (file-expand-wildcards "~/Documents/org/projects/*.org"))))
      (todo "NEXT"
        ((org-agenda-overriding-header "Next Actions")
         (org-agenda-files (file-expand-wildcards "~/Documents/org/projects/*.org"))))))

    ("w" "Workflow Status"
     ((todo "WAIT"
            ((org-agenda-overriding-header "Waiting on External")
             (org-agenda-files org-agenda-files)))
      (todo "REVIEW"
            ((org-agenda-overriding-header "In Review")
             (org-agenda-files org-agenda-files)))
      (todo "PLAN"
            ((org-agenda-overriding-header "In Planning")
             (org-agenda-todo-list-sublevels nil)
             (org-agenda-files org-agenda-files)))
      (todo "BACKLOG"
            ((org-agenda-overriding-header "Project Backlog")
             (org-agenda-todo-list-sublevels nil)
             (org-agenda-files org-agenda-files)))
      (todo "READY"
            ((org-agenda-overriding-header "Ready for Work")
             (org-agenda-files org-agenda-files)))
      (todo "ACTIVE"
            ((org-agenda-overriding-header "Active Projects")
             (org-agenda-files org-agenda-files)))
      (todo "COMPLETED"
            ((org-agenda-overriding-header "Completed Projects")
             (org-agenda-files org-agenda-files)))
      (todo "CANC"
            ((org-agenda-overriding-header "Cancelled Projects")
             (org-agenda-files org-agenda-files)))))))

  (setq org-capture-templates
    `(("t" "Tasks / Projects")
      ("tt" "Task" entry (file+olp "~/Documents/org/todo.org" "Inbox")
           "* TODO %?\n  %U\n  %a\n  %i" :empty-lines 1)

      ("c" "Code")
      ("ct" "Code TODO" entry (file+olp "~/Documents/org/todo.org" "Code")
           "* TODO %? :code:\n  %U\n  %a\n  #+begin_src %^{lang}\n  %i\n  #+end_src" :empty-lines 1)
      ("cb" "Bug" entry (file+olp "~/Documents/org/todo.org" "Code")
           "* TODO [BUG] %? :code:bug:\n  %U\n  %a\n  %i" :empty-lines 1)
      ("cf" "FIXME at point" entry (file+olp "~/Documents/org/todo.org" "Code")
           "* TODO [FIXME] %?  :code:fixme:\n  %U\n  %a\n  Context: %i" :empty-lines 1 :immediate-finish t)
      ("cp" "Project TODO" entry
           (file+headline
            ,(concat "~/Documents/org/projects/"
                     "%(projectile-project-name).org")
            "Tasks")
           "* TODO %?\n  %U\n  %a\n  %i" :empty-lines 1)

      ("j" "Journal Entries")
      ("jj" "Journal" entry
           (file+olp+datetree "~/Documents/org/journal.org")
           "\n* %<%I:%M %p> - Journal :journal:\n\n%?\n\n"
           :clock-in :clock-resume
           :empty-lines 1)
      ("jm" "Meeting" entry
           (file+olp+datetree "~/Documents/org/journal.org")
           "* %<%I:%M %p> - %a :meetings:\n\n%?\n\n"
           :clock-in :clock-resume
           :empty-lines 1)

      ("w" "Workflows")
      ("we" "Checking Email" entry (file+olp+datetree "~/Documents/org/journal.org")
           "* Checking Email :email:\n\n%?" :clock-in :clock-resume :empty-lines 1)

      ("m" "Metrics Capture")
      ("mw" "Weight" table-line (file+headline "~/Documents/org/metrics.org" "Weight")
       "| %U | %^{Weight} | %^{Notes} |" :kill-buffer t)))

  (define-key global-map (kbd "C-c j")
    (lambda () (interactive) (org-capture nil "jj")))

  (efs/org-font-setup))

(use-package org-modern
  :after org
  :hook ((org-mode . org-modern-mode)
         (org-agenda-finalize . org-modern-agenda))
  :custom
  (org-modern-star '("◉" "○" "●" "○" "●" "○" "●"))
  (org-modern-table-vertical 1)
  (org-modern-table-horizontal 0.2)
  (org-modern-tag t)
  (org-modern-priority t)
  (org-modern-todo t)
  (org-modern-timestamp t))

(defun efs/org-mode-visual-fill ()
  (setq visual-fill-column-width 100)
  (visual-fill-column-mode 1))

(use-package visual-fill-column
  :hook (org-mode . efs/org-mode-visual-fill))

;;; ============================================================
;;; Spell Checking — Jinx (fast, whole-buffer, enchant backend)
;;; ============================================================

;; Jinx requires native module compilation with enchant2 + pkg-config.
;; After `just switch`, run: M-x jinx-mode to trigger compilation.
(use-package jinx
  :defer t
  :bind (("M-$" . jinx-correct)
         ("C-M-$" . jinx-languages))
  :config
  (global-jinx-mode 1))

;;; ============================================================
;;; Writing Mode — long-form prose, blog posts, books
;;; ============================================================

;;; Word count with goals — live count in modeline
(use-package wc-mode
  :hook (org-mode . wc-mode)
  :custom
  (wc-modeline-format "[%tw words]")
  :config
  (defun bc/set-word-goal (goal)
    "Set a word count goal for the current buffer."
    (interactive "nWord count goal: ")
    (setq wc-word-goal goal)
    (setq wc-modeline-format (format "[%%tw/%d words]" goal))
    (wc-mode -1)
    (wc-mode 1)
    (message "Word goal set to %d" goal)))

(global-set-key (kbd "C-c W") #'bc/set-word-goal)

;;; Typewriter scrolling — keeps cursor at vertical center
(use-package centered-cursor-mode
  :bind ("C-c -" . centered-cursor-mode))

;;; Thesaurus — synonym/antonym lookup
(use-package powerthesaurus
  :bind (("C-c y t" . powerthesaurus-lookup-synonyms-dwim)
         ("C-c y a" . powerthesaurus-lookup-antonyms-dwim)
         ("C-c y d" . powerthesaurus-lookup-definitions-dwim)))

;;; Dictionary — inline word definitions
(use-package define-word
  :bind (("C-c y w" . define-word-at-point)
         ("C-c y W" . define-word)))

;;; Logos — focus on one section/page at a time
;; Narrows buffer to current org heading or page, step through with ]/[.
(use-package logos
  :bind (("C-c [" . logos-backward-page-dwim)
         ("C-c ]" . logos-forward-page-dwim)
         ("C-c {" . logos-focus-mode))
  :custom
  (logos-outlines-are-pages t)  ; org headings act as page breaks
  (logos-hide-cursor nil)
  (logos-hide-mode-line t)
  (logos-hide-header-line t)
  (logos-hide-buffer-boundaries t)
  (logos-scroll-lock nil)
  (logos-olivetti t))           ; auto-enable olivetti in focus mode

;;; Export — pandoc backend for org (EPUB, DOCX, PDF, etc.)
(use-package ox-pandoc
  :after org)

;;; Export — org to Hugo blog posts
;; Write posts as org subtrees or files, export to Hugo-compatible markdown.
;; Blog dir default: ~/blog/  (customize org-hugo-base-dir per-project)
(use-package ox-hugo
  :after org
  :custom
  (org-hugo-base-dir "~/blog/"))

;;; EPUB reader — read reference books inside Emacs
(use-package nov
  :mode ("\\.epub\\'" . nov-mode)
  :custom
  (nov-text-width 80)
  :hook (nov-mode . (lambda ()
                      (olivetti-mode 1)
                      (visual-line-mode 1))))

;;; Writing mode toggle — one key to enter/exit distraction-free writing
(defvar bc/--writing-mode-prev-config nil
  "Window configuration saved before entering writing mode.")

(defun bc/writing-mode ()
  "Toggle a distraction-free writing environment.
Enables: olivetti (centered text), centered-cursor (typewriter scroll),
wc-mode (word count), hides UI chrome. Restores previous layout on exit."
  (interactive)
  (if bc/--writing-mode-prev-config
      ;; Exit writing mode
      (progn
        (set-window-configuration bc/--writing-mode-prev-config)
        (setq bc/--writing-mode-prev-config nil)
        (olivetti-mode -1)
        (centered-cursor-mode -1)
        (message "Writing mode off"))
    ;; Enter writing mode
    (setq bc/--writing-mode-prev-config (current-window-configuration))
    (delete-other-windows)
    (olivetti-mode 1)
    (centered-cursor-mode 1)
    (display-line-numbers-mode -1)
    (message "Writing mode on — C-c Z to exit")))

(global-set-key (kbd "C-c Z") #'bc/writing-mode)

;;; Blog post capture template
(with-eval-after-load 'org
  (add-to-list 'org-capture-templates
               '("b" "Blog post" entry
                 (file+headline "~/blog/content-org/posts.org" "Drafts")
                 "* TODO %? :blog:\n:PROPERTIES:\n:EXPORT_FILE_NAME: %(format-time-string \"%Y-%m-%d\")-\n:EXPORT_HUGO_BUNDLE:\n:END:\n\n"
                 :empty-lines 1)
               t))

;;; ============================================================
;;; AI — ECA (Editor Code Assistant) — chat, agent, completions
;;; ============================================================

;; ECA: unified AI pair programming — replaces copilot, gptel, aidermacs.
;; One server (eca server) connecting Emacs to any LLM.
;; Config: ~/.config/eca/config.json  API keys: ~/.config/eca/netrc
;; First-time: ECA server binary auto-downloads on first start.
(use-package eca
  :bind (("C-c RET" . eca-send)           ; send region/prompt to LLM
         ("C-c C-RET" . eca-chat)          ; open/switch to chat buffer
         ("C-c M-RET" . eca-menu)          ; transient menu (model/agent/options)
         ("C-c A" . eca-menu))             ; alternate binding
  :custom
  (eca-default-agent "code")
  :config
  (eca-global-mode 1))

;;; ============================================================
;;; AI — Claude Code IDE (MCP-integrated terminal interface)
;;; ============================================================

;; claude-code-ide: bidirectional MCP bridge between Claude Code and Emacs.
;; Exposes xref, diagnostics, imenu, treesit to Claude for richer context.
;; Uses vterm backend; global-auto-revert-mode picks up file changes.
(use-package claude-code-ide
  :vc (:url "https://github.com/manzaltu/claude-code-ide.el" :rev :newest)
  :bind (("C-c C" . claude-code-ide)
         ("C-c C-'" . claude-code-ide-menu))
  :custom
  (claude-code-ide-terminal-backend 'vterm)
  :config
  (claude-code-ide-emacs-tools-setup))

;;; ============================================================
;;; AI — Codex Agent Terminal
;;; ============================================================

;; Declare vterm variables as dynamic so let-binding works in lexical-binding mode.
(defvar vterm-shell)
(defvar vterm-buffer-name)

(defun bc/ai-agent-vterm (name cmd)
  "Launch AI agent CMD in a project-rooted vterm buffer named NAME."
  (let* ((root (or (and (fboundp 'projectile-project-root) (projectile-project-root))
                   default-directory))
         (buf-name (format "*%s: %s*" name (file-name-nondirectory (directory-file-name root))))
         (default-directory root))
    (if (get-buffer buf-name)
        (switch-to-buffer buf-name)
      (let ((vterm-shell cmd)
            (vterm-buffer-name buf-name))
        (vterm)))))

(defun bc/codex ()
  "Launch Codex in the project root."
  (interactive)
  (bc/ai-agent-vterm "Codex" "codex"))

(global-set-key (kbd "C-c X") #'bc/codex)

;;; init.el ends here
