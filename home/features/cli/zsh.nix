# Zsh configuration with home-manager native plugins, Starship P10k-style prompt,
# emacs keybindings, switchable theming, and cross-platform aliases.
{
  lib,
  config,
  pkgs,
  theme,
  ...
}: let
  cfg = config.features.cli.zsh;
  palette = theme.palette;
  # Nerd Font glyphs via JSON Unicode escapes (literal chars get stripped by Nix→TOML)
  g = code: builtins.fromJSON ''"\u${code}"'';
  pl = g "e0b0"; #
  pr = g "e0b2"; #
  iconFolder = g "f07b"; #
  iconBranch = g "e0a0"; #
  iconLinux = g "f17c"; #
  iconApple = g "f179"; #
in {
  options.features.cli.zsh.enable =
    lib.mkEnableOption "enable extended zsh configuration";

  config = lib.mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      autocd = true;

      # --- Plugins (home-manager native) ------------------------------------
      syntaxHighlighting = {
        enable = true;
        highlighters = ["main" "brackets" "pattern" "cursor"];
      };
      autosuggestion = {
        enable = true;
        highlight = "fg=${palette.comment}"; # Dracula comment (#6272a4)
        strategy = ["history" "completion"];
      };
      historySubstringSearch.enable = true;

      # --- Extra plugins (sourced automatically by home-manager) -------------
      plugins = [
        { name = "zsh-autopair";      src = pkgs.zsh-autopair;      file = "share/zsh/zsh-autopair/autopair.zsh"; }
        { name = "zsh-you-should-use"; src = pkgs.zsh-you-should-use; file = "share/zsh/plugins/you-should-use/you-should-use.plugin.zsh"; }
        { name = "zsh-nix-shell";     src = pkgs.zsh-nix-shell;     file = "share/zsh/zsh-nix-shell/nix-shell.plugin.zsh"; }
      ];

      # --- History ----------------------------------------------------------
      history = {
        size = 100000;
        save = 100000;
        path = "$HOME/.zsh_history";
        ignoreDups = true;
        ignoreAllDups = true;
        ignoreSpace = true;
        extended = true;
        share = true;
      };

      # --- Shell Aliases ----------------------------------------------------
      shellAliases = {
        # Navigation
        ".." = "cd ..";
        "..." = "cd ../..";
        "...." = "cd ../../..";

        # File listing (eza)
        ls = "eza";
        ll = "eza -l --icons --git";
        la = "eza -la --icons --git";
        lt = "eza --tree --level=2 --icons";
        lta = "eza --tree --level=2 --icons -a";

        # Modern replacements
        cat = "bat";
        grep = "rg";
        top = "btop";
        ping = "prettyping --nolegend";
        du = "dust";
        df = "duf";
        dig = "doggo";
        watch = "viddy";
        http = "xh";
        cpv = "rsync -pogbr -hhh --backup-dir=/tmp/rsync -e /dev/null --progress";

        # Git shortcuts
        g = "git";
        gs = "git status";
        ga = "git add";
        gc = "git commit";
        gcs = "git commit -S";
        gp = "git push";
        gl = "git pull";
        gd = "git diff";
        gco = "git checkout";
        gb = "git branch";
        glog = "git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
        lg = "lazygit";
        ld = "lazydocker";

        # Docker shortcuts
        dps = "docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'";
        dlog = "docker logs -f";
        dex = "docker exec -it";
        dcu = "docker compose up -d";
        dcd = "docker compose down";
        dcl = "docker compose logs -f";
        dcr = "docker compose restart";

        # Nix shortcuts
        nrs = "sudo nixos-rebuild switch --flake .";
        nrt = "sudo nixos-rebuild test --flake .";
        nfu = "nix flake update";
        nfc = "nix flake check";
        ns = "nix search nixpkgs";
        uj = "ujust";

        # Data formats
        yq = "yq-go"; # YAML processor

        # Infrastructure as Code
        tf = "tofu";
        tfp = "tofu plan";
        tfa = "tofu apply";
        tfi = "tofu init";
        tg = "terragrunt";
        k = "kubectl";
        kgp = "kubectl get pods";
        kgs = "kubectl get svc";
        kga = "kubectl get all";
        kns = "kubectl config set-context --current --namespace";
        kctx = "kubectl config use-context";

        # Modern replacements (new)
        json = "fx"; # Interactive JSON viewer
        img = "chafa"; # Terminal image viewer (Kitty/Sixel)
        vid = "timg"; # Terminal image/video viewer

        # CLI browsers
        web = "w3m"; # Text-mode HTTP browser
        gemini = "amfora"; # Gemini protocol browser
        gopher = "bombadillo"; # Gopher + Gemini + Finger

        # Compression (ouch replaces extract() function)
        x = "ouch decompress"; # Extract any archive: x file.tar.gz
        compress = "ouch compress"; # Compress: compress dir out.tar.gz

        # Task management
        pq = "pueue"; # Task queue
        pqs = "pueue status"; # Queue status
        pqa = "pueue add --"; # Add task: pqa 'long command'
        pql = "pueue log"; # Task logs

        # Nix introspection
        ndt = "nix-diff"; # Diff two Nix derivations
        ntr = "nix-tree"; # Explore Nix store closure sizes

        # Utilities
        reload = "exec zsh";
        myip = "curl -s ifconfig.me";
        ports = "ss -tulanp";
        path = ''echo $PATH | tr ":" "\n"'';
        md = "glow"; # Render markdown
        loc = "tokei"; # Count lines of code
        bench = "hyperfine"; # Benchmark commands
        diff = "difft"; # Syntax-aware diff
        fm = "yazi"; # File manager (also: y to cd on quit)
        gpgkeys = "gpg --list-secret-keys --keyid-format LONG";
        gpgpub = "gpg --armor --export";
        rbwls = "rbw list";

        # Tmux shortcuts (matches oh-my-zsh tmux plugin)
        ts = "tmux new-session -s";
        tss = "tmux new-session -A -s"; # attach-or-create
        ta = "tmux attach -t";
        tad = "tmux attach -d -t";
        tkss = "tmux kill-session -t";
        tl = "tmux list-sessions";

        # Emacs daemon workflow
        emacs = "emacsclient -c -a ''";
        ec = "emacsclient -c -a ''";
        et = "emacsclient -t -a ''";
      } // lib.optionalAttrs pkgs.stdenv.isDarwin {
        # Darwin-specific nix shortcuts
        drs = "darwin-rebuild switch --flake .";
        drt = "darwin-rebuild check --flake .";
      };

      # --- initContent with ordering ----------------------------------------
      initContent = lib.mkMerge [
        # Environment variables (early)
        (lib.mkOrder 100 ''
          export NIX_PATH="nixpkgs=channel:nixos-unstable"
          export NIX_LOG="info"
          export GPG_TTY="$(tty)"
        '')

        # Emacs keybindings, colored man pages, extract function
        (lib.mkOrder 500 ''
          # Explicit emacs keymap -- tmux uses vi keyMode for copy-mode,
          # but we want emacs line-editing in the shell (Ctrl+A/E/K/U/W).
          bindkey -e

          # Colored man pages using Dracula palette via LESS_TERMCAP
          export LESS_TERMCAP_mb=$'\e[1;35m'      # begin blink (purple)
          export LESS_TERMCAP_md=$'\e[1;36m'      # begin bold (cyan)
          export LESS_TERMCAP_me=$'\e[0m'          # end mode
          export LESS_TERMCAP_so=$'\e[01;44;33m'  # begin standout (yellow on blue)
          export LESS_TERMCAP_se=$'\e[0m'          # end standout
          export LESS_TERMCAP_us=$'\e[1;32m'      # begin underline (green)
          export LESS_TERMCAP_ue=$'\e[0m'          # end underline

          # Universal archive extractor
          extract() {
            if [ -f "$1" ]; then
              case "$1" in
                *.tar.bz2)   tar xjf "$1"   ;;
                *.tar.gz)    tar xzf "$1"   ;;
                *.tar.xz)    tar xJf "$1"   ;;
                *.bz2)       bunzip2 "$1"   ;;
                *.rar)       unrar x "$1"   ;;
                *.gz)        gunzip "$1"    ;;
                *.tar)       tar xf "$1"    ;;
                *.tbz2)      tar xjf "$1"   ;;
                *.tgz)       tar xzf "$1"   ;;
                *.zip)       unzip "$1"     ;;
                *.Z)         uncompress "$1";;
                *.7z)        7z x "$1"      ;;
                *)           echo "Cannot extract '$1'" ;;
              esac
            else
              echo "'$1' is not a valid file"
            fi
          }
        '')

        # Shell helper functions
        (lib.mkOrder 600 ''
          # Create a new project directory with git init, direnv, and optional flake template.
          # Usage: mkproject myapp [python|typescript|rust|go|terraform]
          mkproject() {
            local name="''${1:?Usage: mkproject <name> [python|typescript|rust|go|terraform]}"
            local template="$2"
            mkdir -p "$name" && cd "$name" || return 1
            git init
            if [[ -n "$template" ]]; then
              nix flake init -t "''${NIXCFG_REPO:-$HOME/nixcfg}#$template"
              echo "Initialized $template flake template"
            fi
            echo "use flake" > .envrc
            direnv allow
            echo "# $name" > README.md
            echo "Created project $name with git + direnv''${template:+ + $template template}"
          }

          # mkdir and cd into it
          mkcd() { mkdir -p "$1" && cd "$1"; }

          # Quick HTTP server in current directory
          serve() { python3 -m http.server "''${1:-8000}"; }

          # Copy a path to the clipboard (pbcopy on macOS, wl-copy on Linux).
          cpath() {
            local target="''${1:?Usage: cpath <path>}"
            realpath "$target" | tr -d '\n' | ${if pkgs.stdenv.isDarwin then "pbcopy" else "wl-copy"}
            echo "Copied path: $(realpath "$target")"
          }

          # Find unreferenced nix store paths
          nix-stray() {
            nix-store --gc --print-dead 2>/dev/null | head -20
            echo "Run 'nix-collect-garbage -d' to clean up"
          }

          ${lib.optionalString pkgs.stdenv.isLinux ''
          # OCR helpers for screenshots, images, and PDFs (Linux/Wayland only).
          ocrimg() {
            local file="''${1:?Usage: ocrimg <image>}"
            "$HOME/.local/bin/ocr-image" "$file"
          }
          ocrpdf() {
            local file="''${1:?Usage: ocrpdf <pdf> [page] }"
            "$HOME/.local/bin/ocr-pdf" "$file" "''${2:-1}"
          }
          ocrshot() {
            "$HOME/.local/bin/ocr-screenshot"
          }
          ''}
          # Tmux workflow presets
          tdev() {
            tmux new-session -d -s dev -n editor
            tmux split-window -h -t dev:editor
            tmux split-window -v -t dev:editor.2
            tmux send-keys -t dev:editor.2 'git log --oneline -20' C-m
            tmux select-pane -t dev:editor.1
            tmux attach -t dev
          }
          tops() {
            tmux new-session -d -s ops -n monitor
            tmux send-keys -t ops:monitor 'btop' C-m
            tmux split-window -h -t ops:monitor
            tmux split-window -v -t ops:monitor
            tmux select-pane -t ops:monitor.2
            tmux attach -t ops
          }
          tmon() {
            tmux new-session -d -s mon -n logs
            tmux split-window -h -t mon:logs
            tmux split-window -v -t mon:logs.1
            tmux split-window -v -t mon:logs.2
            tmux select-pane -t mon:logs.1
            tmux attach -t mon
          }
        '')

        # Transient prompt: collapse previous prompts to a minimal indicator.
        # home-manager's enableTransience is Fish-only, so we do it manually for zsh.
        (lib.mkOrder 900 ''
          zle-line-init() {
            [[ $CONTEXT == start ]] || return 0
            while true; do
              zle .recursive-edit
              local -i ret=$?
              [[ $ret == 0 && $KEYS == $'\4' ]] || break
              [[ -o ignore_eof ]] || exit 0
            done
            local saved_prompt=$PROMPT
            local saved_rprompt=$RPROMPT
            PROMPT='%F{green}λ%f '
            RPROMPT=""
            zle .reset-prompt
            PROMPT=$saved_prompt
            RPROMPT=$saved_rprompt
            if (( ret )); then
              zle .send-break
            else
              zle .accept-line
            fi
            return ret
          }
          zle -N zle-line-init
        '')

        # Hyprland autostart removed: greetd + tuigreet handles session launch
      ];
    };

    # --- Starship: P10k-inspired powerline prompt ----------------------------
    # 2-line powerline with colored bg segments, pointed  arrows between,
    # and palette colors throughout for theme switching.
    # P10k reference: ~/.dotfiles/zsh/.p10k.zsh (github.com/bmclark/.dotfiles)
    programs.starship = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        palette = theme.starshipPaletteName;
        palettes.${theme.starshipPaletteName} = palette;

        # Left: purple(os+user) → selection(dir) → green(git) →
        # Right: ← selection(context segments) ← purple(time)
        format = lib.concatStrings [
          # --- Left side ---
          "$os"
          "$username"
          "[@](bg:purple fg:comment)"
          "$hostname"
          "[${pl}](fg:purple bg:selection)"
          "$directory"
          "[${pl}](fg:selection bg:green)"
          "$git_branch"
          "$git_status"
          "[${pl}](fg:green)"
          "$fill"
          # --- Right side ---
          "[${pr}](fg:selection)"
          "$nix_shell"
          "$python"
          "$nodejs"
          "$rust"
          "$docker_context"
          "$terraform"
          "$kubernetes"
          "$aws"
          "$cmd_duration"
          "[${pr}](fg:purple bg:selection)"
          "$time"
          "$line_break"
          "$character"
        ];

        character = {
          success_symbol = "[λ](fg:green bold)";
          error_symbol = "[λ](fg:red bold)";
        };

        fill.symbol = " ";

        # --- Left: purple segment (os + user@host) --------------------------
        os = {
          disabled = false;
          format = "[$symbol ](bg:purple fg:fg)";
          symbols = {
            NixOS = "❄";
            Linux = "${iconLinux}";
            Macos = "${iconApple}";
          };
        };

        username = {
          format = "[$user](bg:purple fg:bg bold)";
          show_always = true;
        };

        hostname = {
          format = "[$hostname ](bg:purple fg:bg bold)";
          ssh_only = false;
        };

        # --- Left: selection segment (directory) -----------------------------
        directory = {
          format = "[ ${iconFolder} $path](bg:selection fg:cyan bold)[$read_only ](bg:selection fg:red)";
          truncation_length = 3;
          truncation_symbol = ".../";
          read_only = " 󰌾";
          substitutions = {
            "Documents" = "󰈙 ";
            "Downloads" = " ";
            "Music" = " ";
            "Pictures" = " ";
          };
        };

        # --- Left: green segment (git) ---------------------------------------
        git_branch = {
          format = "[ $symbol$branch ](bg:green fg:bg)";
          symbol = "${iconBranch}";
        };

        git_status = {
          format = "[$all_status$ahead_behind](bg:green fg:bg)";
          ahead = "⇡$count";
          behind = "⇣$count";
          diverged = "⇕⇡$ahead_count⇣$behind_count";
          modified = "!$count";
          staged = "+$count";
          untracked = "?$count";
          deleted = "✘$count";
          stashed = "*$count";
          conflicted = "~$count";
        };

        # --- Right: selection segment (context info) -------------------------
        # Thin  separators between items sharing the selection bg.
        nix_shell = {
          format = "[ ❄ $state ](bg:selection fg:cyan)";
          symbol = "";
        };

        python = {
          format = "[](bg:selection fg:comment)[  $version ](bg:selection fg:green)";
          symbol = "";
        };

        nodejs = {
          format = "[](bg:selection fg:comment)[  $version ](bg:selection fg:green)";
          symbol = "";
        };

        rust = {
          format = "[](bg:selection fg:comment)[  $version ](bg:selection fg:orange)";
          symbol = "";
        };

        docker_context = {
          format = "[](bg:selection fg:comment)[  $context ](bg:selection fg:cyan)";
          symbol = "";
        };

        terraform = {
          format = "[](bg:selection fg:comment)[ 󱁢 $workspace ](bg:selection fg:purple)";
        };

        kubernetes = {
          disabled = false;
          format = "[](bg:selection fg:comment)[ 󱃾 $context ](bg:selection fg:purple)";
          detect_files = ["Helmfile.yaml" "helmfile.yaml"];
        };

        aws = {
          disabled = false;
          format = "[](bg:selection fg:comment)[ 󰸏 $profile ](bg:selection fg:orange)";
        };

        cmd_duration = {
          format = "[](bg:selection fg:comment)[ 󱎫 $duration ](bg:selection fg:yellow)";
          min_time = 3000;
        };

        # --- Right: purple segment (time) ------------------------------------
        time = {
          disabled = false;
          format = "[ $time ](bg:purple fg:bg bold)";
          time_format = "%I:%M %p";
        };

        # Disable unused cloud modules
        gcloud.disabled = true;
        azure.disabled = true;
      };
    };
  };
}
