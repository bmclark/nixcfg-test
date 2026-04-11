# VS Code with switchable theme, Emacs MCX keybindings, Nix LSP, AI-agent-first
# settings, and layered extensions (global base + per-project recommendations).
# Platform-aware: FHS wrapper on Linux (needed for extensions), standard on macOS.
{
  config,
  lib,
  pkgs,
  theme,
  nix-vscode-extensions,
  ...
}:
with lib; let
  cfg = config.features.development.vscode;
  marketplace =
    nix-vscode-extensions.extensions.${pkgs.stdenv.system}.vscode-marketplace;
in {
  options.features.development.vscode.enable = mkEnableOption "enable vscode";

  config = mkIf cfg.enable {
    # Replace Nix store symlinks with writable copies so VS Code can write settings.
    # Runs after home-manager links are created; converts symlinks to mutable copies.
    home.activation.vscodeMutableSettings = lib.hm.dag.entryAfter ["writeBoundary"] ''
      for f in "$HOME/.config/Code/User/settings.json" \
               "$HOME/.config/Code/User/keybindings.json"; do
        if [ -L "$f" ]; then
          target=$(readlink "$f")
          run rm "$f"
          run cp "$target" "$f"
          run chmod u+w "$f"
        fi
      done
    '';

    programs.vscode = {
      enable = true;
      # FHS wrapper needed on Linux for extension compatibility; unnecessary on macOS
      package =
        if pkgs.stdenv.isLinux
        then pkgs.vscode.fhs
        else pkgs.vscode;

      profiles.default = {
        enableUpdateCheck = false;
        enableExtensionUpdateCheck = false;

        extensions = with pkgs.vscode-extensions; [
          # Theme
          dracula-theme.theme-dracula

          # Git
          eamodio.gitlens

          # Keybindings: Emacs MCX provides Emacs keybindings (Ctrl+A/E/K/N/P/F/B)
          tuttieee.emacs-mcx

          # AI assistants
          github.copilot
          # anthropic.claude-code — installed via CLI package; nixpkgs hash is stale

          # Nix: language support + formatting
          jnoortheen.nix-ide

          # Editor essentials
          editorconfig.editorconfig
          usernamehw.errorlens

          # GitHub integration
          github.vscode-github-actions
          github.vscode-pull-request-github

          # Remote development
          ms-vscode-remote.remote-containers
          ms-vscode-remote.remote-ssh

          # Language formatters (paired with per-language settings below)
          charliermarsh.ruff # Python: linting + formatting
          esbenp.prettier-vscode # JS/TS/JSON/YAML/Markdown formatting
          hashicorp.terraform # Terraform/HCL language support + formatting

          # Data formats
          redhat.vscode-yaml
          tamasfe.even-better-toml

          # Markdown
          davidanson.vscode-markdownlint
          yzhang.markdown-all-in-one

          # Docker & Kubernetes
          ms-azuretools.vscode-docker
          ms-kubernetes-tools.vscode-kubernetes-tools

          # Infrastructure
          redhat.ansible
          hashicorp.hcl

          # Shell
          timonwong.shellcheck

          # Nix/direnv integration: auto-loads .envrc in VS Code
          mkhl.direnv
        ]
        ++ [
          # Marketplace extensions (via nix-vscode-extensions)
          marketplace.vivaxy.vscode-conventional-commits
        ];

        userSettings = {
          # --- Theme & Appearance ---
          "workbench.colorTheme" = theme.vscodeThemeName;
          "workbench.iconTheme" = "vs-seti";

          # --- Font ---
          "editor.fontFamily" = "'FiraCode Nerd Font', 'Fira Code', monospace";
          "editor.fontSize" = 14;
          "editor.fontLigatures" = true;

          # --- Terminal ---
          "terminal.integrated.fontFamily" = "'FiraCode Nerd Font', monospace";
          "terminal.integrated.fontSize" = 12;
          "terminal.integrated.defaultProfile.linux" = "zsh";
          "terminal.integrated.defaultProfile.osx" = "zsh";
          "terminal.integrated.scrollback" = 10000;
          "terminal.integrated.enablePersistentSessions" = true;

          # --- Editor ---
          "editor.formatOnSave" = true;
          "editor.tabSize" = 2;
          "editor.minimap.enabled" = false;
          "editor.bracketPairColorization.enabled" = true;
          "editor.wordWrap" = "on";
          "editor.cursorStyle" = "block";
          "editor.renderWhitespace" = "boundary";
          "editor.suggestSelection" = "first";
          "editor.linkedEditing" = true;
          "editor.inlineSuggest.enabled" = true;

          # --- Files ---
          "files.trimTrailingWhitespace" = true;
          "files.insertFinalNewline" = true;
          "files.autoSave" = "afterDelay";
          "files.autoSaveDelay" = 1000;

          # File watching: exclude paths that AI agents and Nix generate rapidly
          "files.watcherExclude" = {
            "**/.git/objects/**" = true;
            "**/.git/subtree-cache/**" = true;
            "**/node_modules/**" = true;
            "**/.direnv/**" = true;
            "**/result/**" = true;
            "**/.devenv/**" = true;
          };

          "search.exclude" = {
            "**/node_modules" = true;
            "**/result" = true;
            "**/.direnv" = true;
            "**/.devenv" = true;
          };

          # --- Nix IDE: nil language server + alejandra formatter ---
          "nix.enableLanguageServer" = true;
          "nix.serverPath" = "nil";
          "nix.serverSettings" = {
            nil = {
              formatting.command = ["alejandra"];
            };
          };

          # --- Copilot: inline autocomplete ---
          "github.copilot.enable" = {"*" = true;};
          "github.copilot.editor.enableAutoCompletions" = true;

          # --- Claude Code ---
          "claude-code.enableTerminalIntegration" = true;

          # --- Dev Containers: inject base extensions into every container ---
          "dev.containers.defaultExtensions" = [
            "editorconfig.editorconfig"
            "eamodio.gitlens"
            "tuttieee.emacs-mcx"
            "github.copilot"
          ];

          # --- Git ---
          # Explicit path needed: FHS wrapper doesn't see /etc/profiles/per-user/*/bin
          "git.path" = "git";
          "git.autofetch" = true;
          "git.confirmSync" = false;
          "git.enableSmartCommit" = true;

          # --- Emacs MCX ---
          # Emacs MCX provides Ctrl+A/E/K/N/P/F/B for text editing.
          # Conflicts resolved: Ctrl+B/P are rebound below for VS Code commands,
          # which take precedence over Emacs MCX in the right contexts.
          "emacs-mcx.cursorMoveOnFindWidget" = true;
          "emacs-mcx.useMetaPrefixMacCmd" = false; # Ctrl only, no Meta/Alt prefix
          "emacs-mcx.useMetaPrefixCtrlLeftBracket" = false;

          # --- Language-specific settings (per-workspace formatters) ---

          # Python: ruff for both linting and formatting
          "[python]" = {
            "editor.defaultFormatter" = "charliermarsh.ruff";
            "editor.tabSize" = 4;
            "editor.formatOnSave" = true;
            "editor.codeActionsOnSave" = {
              "source.fixAll.ruff" = "explicit";
              "source.organizeImports.ruff" = "explicit";
            };
          };

          # TypeScript / JavaScript: prettier
          "[typescript]" = {
            "editor.defaultFormatter" = "esbenp.prettier-vscode";
          };
          "[typescriptreact]" = {
            "editor.defaultFormatter" = "esbenp.prettier-vscode";
          };
          "[javascript]" = {
            "editor.defaultFormatter" = "esbenp.prettier-vscode";
          };
          "[javascriptreact]" = {
            "editor.defaultFormatter" = "esbenp.prettier-vscode";
          };

          # JSON / JSONC: prettier
          "[json]" = {
            "editor.defaultFormatter" = "esbenp.prettier-vscode";
          };
          "[jsonc]" = {
            "editor.defaultFormatter" = "esbenp.prettier-vscode";
          };

          # YAML: prettier
          "[yaml]" = {
            "editor.defaultFormatter" = "esbenp.prettier-vscode";
          };

          # Markdown: prettier (markdownlint handles linting separately)
          "[markdown]" = {
            "editor.defaultFormatter" = "esbenp.prettier-vscode";
            "editor.wordWrap" = "wordWrapColumn";
            "editor.wordWrapColumn" = 80;
          };

          # Terraform / HCL: terraform-ls
          "[terraform]" = {
            "editor.defaultFormatter" = "hashicorp.terraform";
            "editor.tabSize" = 2;
          };
          "[terraform-vars]" = {
            "editor.defaultFormatter" = "hashicorp.terraform";
          };

          # TOML: even-better-toml
          "[toml]" = {
            "editor.defaultFormatter" = "tamasfe.even-better-toml";
          };

          # Shell: shfmt via shellcheck
          "[shellscript]" = {
            "editor.tabSize" = 2;
          };

          # --- Updates & Telemetry: off ---
          # Disable to prevent writes to Nix-managed (read-only) settings.json
          "update.mode" = "none";
          "extensions.autoUpdate" = false;
          "telemetry.telemetryLevel" = "off";
          "workbench.enableExperiments" = false;
        };

        keybindings = [
          # --- VS Code navigation (always available) ---
          {
            key = "ctrl+`";
            command = "workbench.action.terminal.toggleTerminal";
          }
          {
            key = "ctrl+\\";
            command = "workbench.action.splitEditor";
          }
          {
            key = "ctrl+shift+f";
            command = "workbench.action.findInFiles";
          }
          {
            key = "ctrl+1";
            command = "workbench.action.focusFirstEditorGroup";
          }
          {
            key = "ctrl+2";
            command = "workbench.action.focusSecondEditorGroup";
          }

          # --- Emacs MCX conflict resolution ---
          # Ctrl+B: sidebar toggle ONLY when focus is NOT in the editor
          # (in editor, Emacs MCX uses Ctrl+B for backward-char)
          {
            key = "ctrl+b";
            command = "workbench.action.toggleSidebarVisibility";
            when = "!editorTextFocus";
          }
          # Ctrl+P: quick open ONLY when focus is NOT in the editor
          # (in editor, Emacs MCX uses Ctrl+P for previous-line)
          {
            key = "ctrl+p";
            command = "workbench.action.quickOpen";
            when = "!editorTextFocus";
          }
          # Alt+P: quick open from anywhere (including editor) as alternative
          {
            key = "alt+p";
            command = "workbench.action.quickOpen";
          }
          # Alt+X: command palette (Emacs M-x equivalent)
          {
            key = "alt+x";
            command = "workbench.action.showCommands";
          }
          # Ctrl+X Ctrl+F: open file (Emacs find-file)
          {
            key = "ctrl+x ctrl+f";
            command = "workbench.action.quickOpen";
          }
          # Ctrl+X Ctrl+S: save (Emacs save-buffer) — already default but explicit
          {
            key = "ctrl+x ctrl+s";
            command = "workbench.action.files.save";
          }
          # Ctrl+X K: close editor (Emacs kill-buffer)
          {
            key = "ctrl+x k";
            command = "workbench.action.closeActiveEditor";
          }
          # Ctrl+X 2: split editor below (Emacs split-window-below)
          {
            key = "ctrl+x 2";
            command = "workbench.action.splitEditorDown";
          }
          # Ctrl+X 3: split editor right (Emacs split-window-right)
          {
            key = "ctrl+x 3";
            command = "workbench.action.splitEditor";
          }
          # Ctrl+X O: switch between editor groups (Emacs other-window)
          {
            key = "ctrl+x o";
            command = "workbench.action.focusNextGroup";
          }
          # Ctrl+X 1: close other editors (Emacs delete-other-windows)
          {
            key = "ctrl+x 1";
            command = "workbench.action.closeEditorsInOtherGroups";
          }
        ];
      };
    };
  };
}
