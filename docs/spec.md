# NixCfg Technical Specification

Detailed technical specification for every module in the nixcfg unified configuration.

---

## 1. Module Pattern

All feature modules follow this pattern:

```nix
{ config, lib, pkgs, ... }:
let
  cfg = config.features.<category>.<module>;
in {
  options.features.<category>.<module> = {
    enable = lib.mkEnableOption "<description>";
  };

  config = lib.mkIf cfg.enable {
    # module configuration
  };
}
```

Platform guards use `lib.mkIf pkgs.stdenv.isLinux` / `lib.mkIf pkgs.stdenv.isDarwin`.

---

## 2. Git (`home/features/development/git.nix`)

```nix
programs.git = {
  enable = true;
  userName = "Bryan Clark";
  userEmail = "bryan@bclark.net";

  extraConfig = {
    init.defaultBranch = "main";
    push.autoSetupRemote = true;
    pull.rebase = true;
    core.editor = "emacs";
    merge.conflictStyle = "diff3";
    diff.colorMoved = "default";
    rerere.enabled = true;
  };

  delta = {
    enable = true;
    options = {
      syntax-theme = "Dracula";
      line-numbers = true;
      side-by-side = true;
      navigate = true;
    };
  };

  aliases = {
    st = "status -sb";
    co = "checkout";
    br = "branch";
    ci = "commit";
    lg = "log --oneline --graph --decorate --all";
    unstage = "reset HEAD --";
    last = "log -1 HEAD";
    amend = "commit --amend --no-edit";
  };

  ignores = [ ".DS_Store" ".direnv/" "result" "result-*" ];
};
```

---

## 3. Zsh (`home/features/cli/zsh.nix`)

### Plugins

```nix
programs.zsh = {
  syntaxHighlighting = {
    enable = true;
    highlighters = [ "main" "brackets" "pattern" "cursor" ];
  };
  autosuggestion = {
    enable = true;
    highlight = "fg=#6272a4";  # Dracula comment color
    strategy = [ "history" "completion" ];
  };
  historySubstringSearch.enable = true;  # already present
};
```

### History

```nix
history = {
  size = 100000;
  save = 100000;
  ignoreAllDups = true;
  ignoreSpace = true;
  extended = true;
  share = true;
};
```

### Aliases

```nix
shellAliases = {
  # Navigation
  ".." = "cd ..";
  "..." = "cd ../..";
  "...." = "cd ../../..";

  # Modern CLI replacements
  ls = "eza --icons --group-directories-first";
  ll = "eza -la --icons --group-directories-first";
  la = "eza -a --icons --group-directories-first";
  lt = "eza --tree --level=2 --icons";
  cat = "bat";
  grep = "rg";
  ps = "procs";
  top = "htop";

  # Git shortcuts
  g = "git";
  gs = "git status -sb";
  ga = "git add";
  gc = "git commit";
  gp = "git push";
  gl = "git pull";
  gd = "git diff";
  gco = "git checkout";
  gb = "git branch";
  glog = "git log --oneline --graph --decorate --all";

  # Nix
  nrs = "sudo nixos-rebuild switch --flake .";  # Linux
  nfu = "nix flake update";

  # Utilities
  reload = "exec zsh";
  myip = "curl -s ifconfig.me";
  ports = "ss -tulanp";
  path = "echo $PATH | tr ':' '\\n'";
};
```

### initContent

```nix
initContent = lib.mkMerge [
  # Environment variables
  (lib.mkOrder 100 ''
    export NIX_PATH="nixpkgs=flake:nixpkgs"
  '')

  # Shell setup: emacs keymap, colored man pages, extract function
  (lib.mkOrder 500 ''
    # Explicit emacs keymap (default, but explicit since tmux uses vi for copy-mode)
    bindkey -e

    # Dracula-colored man pages
    export LESS_TERMCAP_mb=$'\e[1;31m'      # begin bold       -- red
    export LESS_TERMCAP_md=$'\e[1;36m'      # begin bold       -- cyan (#8be9fd)
    export LESS_TERMCAP_me=$'\e[0m'         # end mode
    export LESS_TERMCAP_se=$'\e[0m'         # end standout
    export LESS_TERMCAP_so=$'\e[1;33;44m'   # begin standout   -- yellow on blue
    export LESS_TERMCAP_ue=$'\e[0m'         # end underline
    export LESS_TERMCAP_us=$'\e[1;32m'      # begin underline  -- green (#50fa7b)

    # Universal archive extractor
    extract() {
      if [ -f "$1" ]; then
        case "$1" in
          *.tar.bz2) tar xjf "$1" ;;
          *.tar.gz)  tar xzf "$1" ;;
          *.tar.xz)  tar xJf "$1" ;;
          *.bz2)     bunzip2 "$1" ;;
          *.rar)     unrar x "$1" ;;
          *.gz)      gunzip "$1" ;;
          *.tar)     tar xf "$1" ;;
          *.tbz2)    tar xjf "$1" ;;
          *.tgz)     tar xzf "$1" ;;
          *.zip)     unzip "$1" ;;
          *.Z)       uncompress "$1" ;;
          *.7z)      7z x "$1" ;;
          *)         echo "'$1' cannot be extracted" ;;
        esac
      else
        echo "'$1' is not a valid file"
      fi
    }
  '')

  # Hyprland autostart (Linux only)
  (lib.mkIf pkgs.stdenv.isLinux (lib.mkOrder 1000 ''
    if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" -eq 1 ]; then
      exec Hyprland
    fi
  ''))
];
```

### Additional Zsh Plugins (via packages)

```nix
# In cli/default.nix or zsh.nix
home.packages = with pkgs; [
  nix-zsh-completions   # tab completion for nix commands
  zsh-you-should-use    # alias reminders
  zsh-autopair          # auto-close brackets/quotes
  zsh-nix-shell         # proper zsh in nix-shell
];
```

### Companion Programs

```nix
# programs.direnv
programs.direnv = {
  enable = true;
  enableZshIntegration = true;
  nix-direnv.enable = true;  # fast, persistent use_nix
};

# programs.nix-index
programs.nix-index = {
  enable = true;
  enableZshIntegration = true;
};

# programs.dircolors
programs.dircolors = {
  enable = true;
  enableZshIntegration = true;
};

# programs.bat
programs.bat = {
  enable = true;
  config.theme = "Dracula";
};
```

---

## 4. Starship Prompt

Dracula palette definition:

```nix
programs.starship.settings = {
  palette = "dracula";
  palettes.dracula = {
    bg = "#282a36";
    fg = "#f8f8f2";
    cyan = "#8be9fd";
    green = "#50fa7b";
    orange = "#ffb86c";
    pink = "#ff79c6";
    purple = "#bd93f9";
    red = "#ff5555";
    yellow = "#f1fa8c";
    comment = "#6272a4";
  };

  format = lib.concatStrings [
    "[](purple)"
    "$username"
    "$hostname"
    "[](bg:pink fg:purple)"
    "$directory"
    "[](bg:cyan fg:pink)"
    "$git_branch"
    "$git_status"
    "[](bg:yellow fg:cyan)"
    "$cmd_duration"
    "[](yellow)"
    "$fill"
    "[](green)"
    "$nix_shell"
    "$python"
    "$nodejs"
    "$rust"
    "[](green)"
    "$line_break"
    "$character"
  ];

  username = {
    format = "[ $user ]($style)";
    style_user = "bg:purple fg:bg";
    show_always = true;
  };

  hostname = {
    format = "[@$hostname ]($style)";
    style = "bg:purple fg:bg";
    ssh_only = false;
  };

  directory = {
    format = "[ $path ]($style)";
    style = "bg:pink fg:bg";
    truncation_length = 3;
    truncation_symbol = ".../";
  };

  git_branch = {
    format = "[ $symbol$branch ]($style)";
    style = "bg:cyan fg:bg";
    symbol = " ";
  };

  git_status = {
    format = "[$all_status$ahead_behind]($style)";
    style = "bg:cyan fg:bg";
  };

  cmd_duration = {
    format = "[ $duration ]($style)";
    style = "bg:yellow fg:bg";
    min_time = 2000;
  };

  nix_shell = {
    format = "[ $symbol$state ]($style)";
    style = "bg:green fg:bg";
    symbol = "❄️ ";
  };

  character = {
    success_symbol = "[❯](green)";
    error_symbol = "[❯](red)";
  };

  fill.symbol = " ";
};
```

### Transient Prompt (zsh initContent)

```zsh
# Transient prompt -- collapse previous prompts to minimal ❯
zle-line-init() {
  emulate -L zsh
  [[ $CONTEXT == start ]] || return 0
  while true; do
    zle .recursive-edit
    local -i ret=$?
    [[ $ret == 0 && $KEYS == $'\4' ]] || break
    [[ -o ignore_eof ]] || exit 0
  done
  local saved_prompt=$PROMPT
  local saved_rprompt=$RPROMPT
  PROMPT='%F{green}❯%f '
  RPROMPT=''
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
```

---

## 5. Tmux (`home/features/cli/tmux.nix`)

```nix
programs.tmux = {
  enable = true;
  prefix = "C-a";
  mouse = true;
  historyLimit = 100000;
  baseIndex = 1;
  escapeTime = 0;
  keyMode = "vi";
  terminal = "tmux-256color";
  shell = "${pkgs.zsh}/bin/zsh";

  plugins = with pkgs.tmuxPlugins; [
    sensible
    {
      plugin = dracula;
      extraConfig = ''
        set -g @dracula-show-battery true
        set -g @dracula-show-powerline true
        set -g @dracula-plugins "cpu-usage ram-usage battery"
        set -g @dracula-show-left-icon session
      '';
    }
    yank
    pain-control
    {
      plugin = logging;
      extraConfig = ''
        set -g @logging-path "$HOME/tmux-logs"
        set -g @screen-capture-path "$HOME/tmux-logs"
        set -g @save-complete-history-path "$HOME/tmux-logs"
      '';
    }
  ];

  extraConfig = ''
    # Split panes with | and -
    bind | split-window -h -c "#{pane_current_path}"
    bind - split-window -v -c "#{pane_current_path}"

    # Window navigation with Shift+arrows
    bind -n S-Left previous-window
    bind -n S-Right next-window

    # Pane navigation with Alt+arrows
    bind -n M-Left select-pane -L
    bind -n M-Right select-pane -R
    bind -n M-Up select-pane -U
    bind -n M-Down select-pane -D

    # Pane resize with Ctrl+Shift+arrows
    bind -n C-S-Left resize-pane -L 2
    bind -n C-S-Right resize-pane -R 2
    bind -n C-S-Up resize-pane -U 2
    bind -n C-S-Down resize-pane -D 2

    # RGB color support for Ghostty
    set -ga terminal-overrides ",xterm-ghostty:Tc"

    # New windows/panes in current directory
    bind c new-window -c "#{pane_current_path}"
  '';
};
```

---

## 6. Atuin (`home/features/cli/atuin.nix`)

```nix
programs.atuin = {
  enable = true;
  enableZshIntegration = true;
  settings = {
    auto_sync = false;          # local-only, no cloud sync
    search_mode = "fuzzy";
    filter_mode = "global";
    style = "compact";
    show_preview = true;
    enter_accept = true;
    update_check = false;
  };
};
```

---

## 7. Ghostty (`home/features/cli/ghostty.nix`)

```nix
programs.ghostty = {
  enable = true;
  settings = {
    # Font
    font-family = "FiraCode Nerd Font";
    font-size = 12;

    # Theme
    theme = "Dracula";
    window-theme = "dark";

    # Scrollback
    scrollback-limit = 100000;

    # Clipboard
    clipboard-read = "allow";
    clipboard-write = "allow";
    copy-on-select = "clipboard";

    # Window
    window-padding-x = 4;
    window-padding-y = 4;
    confirm-close-surface = false;
  };
};
```

---

## 8. Fonts (`home/features/desktop/fonts.nix`)

```nix
fonts.packages = with pkgs; [
  # Primary coding fonts
  fira-code
  fira-code-symbols
  nerd-fonts.fira-code

  # Additional coding fonts
  hack-font                    # user's preferred font
  nerd-fonts.jetbrains-mono    # waybar/wofi/dunst CSS
  nerd-fonts.symbols-only      # pure icon fallback
  meslo-lgs-nf                 # P10k compat

  # UI fonts
  font-awesome_5
  noto-fonts
];

fonts.fontconfig.defaultFonts.monospace = [
  "FiraCode Nerd Font"
  "Hack"
  "JetBrainsMono Nerd Font"
];
```

---

## 9. VS Code (`home/features/development/vscode.nix`)

### Package

```nix
programs.vscode = {
  enable = true;
  package = if pkgs.stdenv.isLinux then pkgs.vscode.fhs else pkgs.vscode;
};
```

### Settings

```nix
userSettings = {
  # Theme
  "workbench.colorTheme" = "Dracula";
  "workbench.iconTheme" = "vs-seti";

  # Font
  "editor.fontFamily" = "'FiraCode Nerd Font', 'Hack', monospace";
  "editor.fontSize" = 14;
  "editor.fontLigatures" = true;
  "terminal.integrated.fontFamily" = "'FiraCode Nerd Font'";
  "terminal.integrated.fontSize" = 12;

  # Editor behavior
  "editor.formatOnSave" = true;
  "editor.tabSize" = 2;
  "editor.minimap.enabled" = false;
  "editor.bracketPairColorization.enabled" = true;
  "editor.wordWrap" = "on";
  "editor.cursorStyle" = "block";
  "editor.renderWhitespace" = "boundary";

  # Files
  "files.trimTrailingWhitespace" = true;
  "files.insertFinalNewline" = true;
  "files.autoSave" = "afterDelay";

  # Terminal
  "terminal.integrated.defaultProfile.linux" = "zsh";
  "terminal.integrated.defaultProfile.osx" = "zsh";

  # Nix IDE
  "nix.enableLanguageServer" = true;
  "nix.serverPath" = "nil";
  "nix.serverSettings".nil.formatting.command = [ "alejandra" ];

  # Git
  "git.autofetch" = true;
  "git.confirmSync" = false;
  "git.enableSmartCommit" = true;

  # Telemetry
  "telemetry.telemetryLevel" = "off";

  # Emacs MCX
  "emacs-mcx.cursorMoveOnFindWidget" = true;
};
```

---

## 10. Firefox (`home/features/desktop/firefox.nix`)

### Extensions (by addon ID)

```nix
profiles.default.extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
  ublock-origin           # ad/tracker blocker
  privacy-badger           # learning tracker blocker
  bitwarden                # password manager
  dracula-dark-colorscheme # browser UI theme
  darkreader               # dark mode for all sites
  localcdn                 # CDN emulation, privacy
  clearurls                # strip tracking parameters
  cookie-autodelete        # auto-clear cookies after tab close
  multi-account-containers # isolate browsing contexts
  canvasblocker            # anti-fingerprinting
];
```

---

## 11. Chromium (`home/features/desktop/chromium.nix`)

```nix
programs.chromium = {
  enable = true;
  extensions = [
    "nngceckbapebfimnlniiiahkandclblb"  # Bitwarden
    "eimadpbcbfnmbkopoojfekhnkhdbieeh"  # Dark Reader
    "gafhhbahpojnjfhpepjjfjojbpghfkbl"  # Dracula Theme
  ];
  commandLineArgs = [
    "--disable-features=WebRtcAllowInputVolumeAdjustment"
    "--disable-reading-from-canvas"
  ];
};
```

---

## 12. Theme System

### Palette Interface

Every theme file exports this structure:

```nix
{
  palette = {
    bg        = "#282a36";    # background
    fg        = "#f8f8f2";    # foreground
    comment   = "#6272a4";    # muted text
    cyan      = "#8be9fd";
    green     = "#50fa7b";
    orange    = "#ffb86c";
    pink      = "#ff79c6";
    purple    = "#bd93f9";
    red       = "#ff5555";
    yellow    = "#f1fa8c";
    selection = "#44475a";    # selection/highlight bg
  };
}
```

### Flake Wiring

```nix
# flake.nix
let
  theme = builtins.getEnv "NIXCFG_THEME";
  themeName = if theme == "" then "dracula" else theme;
in {
  # Pass through specialArgs
  specialArgs = { inherit themeName; };
}
```

### Module Usage

```nix
# Any module that needs theme colors
{ themeName, ... }:
let
  palette = (import ../../themes/${themeName}.nix).palette;
in {
  # Use palette.bg, palette.purple, etc.
}
```

### Justfile Recipe

```just
# Switch theme and rebuild
theme THEME="dracula":
  NIXCFG_THEME={{THEME}} just switch
```

---

## 13. Hyprland Rice Highlights

### Layer Rules

```nix
layerrule = [
  "blur, gtk-layer-shell"
  "blur, waybar"
  "blur, wofi"
  "ignorealpha 0.1, gtk-layer-shell"
  "ignorealpha 0.1, waybar"
  "ignorealpha 0.1, wofi"
];
```

### Window Rules (key examples)

```nix
windowrulev2 = [
  # Float common dialogs
  "float, class:^(?i:file_progress|confirm|dialog|download|notification|error|splash)$"
  "float, title:^(Open File|Save File|branchdialog)$"

  # PiP
  "float, title:^(Picture-in-Picture)$"
  "pin, title:^(Picture-in-Picture)$"
  "size 480 270, title:^(Picture-in-Picture)$"

  # Workspace assignments
  "workspace 1, class:^(Emacs)$"
  "workspace 2, class:^(firefox)$"
  "workspace 3, class:^(code-url-handler)$"

  # Full opacity on browsers
  "opacity 1.0 override 1.0, class:^(firefox|chromium-browser)$"
];
```

### Tuned Settings

```nix
general = {
  gaps_in = 5;
  gaps_out = 10;
};

decoration = {
  active_opacity = 0.95;   # was 0.9, more readable
  inactive_opacity = 0.85;
};

gestures.workspace_swipe = true;
```

### Plugin

```nix
plugins = with pkgs.hyprlandPlugins; [ hyprexpo ];
# Bind: "$mainMod, Tab, hyprexpo:expo, toggle"
```

---

## 14. Cross-Platform Keyboard Matrix

| Action | NixOS Key | macOS Physical Key | Karabiner Output | App Receives |
|--------|-----------|-------------------|-----------------|-------------|
| Tmux prefix | Ctrl+A | Cmd+A | Ctrl+A | Tmux activates |
| Copy (terminal) | Ctrl+Shift+C | Cmd+Shift+C | Ctrl+Shift+C | Clipboard copy |
| Paste (terminal) | Ctrl+Shift+V | Cmd+Shift+V | Ctrl+Shift+V | Clipboard paste |
| VS Code palette | Ctrl+Shift+P | Cmd+Shift+P | Ctrl+Shift+P | Command palette |
| Line start (zsh) | Ctrl+A | Cmd+A | Ctrl+A | Cursor to BOL |
| Kill line (zsh) | Ctrl+K | Cmd+K | Ctrl+K | Kill to EOL |
| Undo (editor) | Ctrl+Z | Cmd+Z | Ctrl+Z | Undo |
| Quit app | Ctrl+Q | Cmd+Q | Ctrl+Q | **No-op** (edge case) |

**Edge case:** Cmd+Q on macOS becomes Ctrl+Q via Karabiner, which does not quit applications. Users must use the app's quit menu or configure an explicit Karabiner exception for Cmd+Q.
