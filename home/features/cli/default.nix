# CLI tools module: shell, terminal, multiplexer, history, and always-on utilities.
{
  pkgs,
  config,
  lib,
  theme,
  ...
}: let
  palette = theme.palette;
  nixcfgRepo = "${config.home.homeDirectory}/nixcfg";
  tailscaleCli =
    if pkgs.stdenv.isDarwin
    then
      pkgs.writeShellApplication {
        name = "tailscale";
        text = ''
          if [[ ! -x /Applications/Tailscale.app/Contents/MacOS/Tailscale ]]; then
            echo "Tailscale.app is not installed in /Applications" >&2
            exit 1
          fi
          exec /Applications/Tailscale.app/Contents/MacOS/Tailscale "$@"
        '';
      }
    else pkgs.tailscale;
in {
  imports = [
    ./fish.nix
    ./fzf.nix
    ./zsh.nix
    ./ghostty.nix
    ./cmux.nix
    ./tmux.nix
    ./atuin.nix
  ];

  home.sessionPath = ["$HOME/.local/bin"];
  home.sessionVariables.NIXCFG_REPO = nixcfgRepo;
  xdg.configFile."just/justfile".text = builtins.readFile ./ujust.just;

  home.file.".local/bin/ujust" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail
      : "''${NIXCFG_REPO:=${nixcfgRepo}}"
      export NIXCFG_REPO
      exec just \
        --justfile "$HOME/.config/just/justfile" \
        --working-directory "$PWD" \
        "$@"
    '';
  };

  assertions = [
    {
      assertion = !(config.features.cli.fish.enable && config.features.cli.zsh.enable);
      message = "Enable only one shell: either features.cli.fish or features.cli.zsh";
    }
  ];

  # --- Shell Integrations ---------------------------------------------------
  programs.zoxide = {
    enable = true;
    enableFishIntegration = config.features.cli.fish.enable;
    enableZshIntegration = config.features.cli.zsh.enable;
  };

  programs.eza = {
    enable = true;
    enableFishIntegration = config.features.cli.fish.enable;
    enableZshIntegration = config.features.cli.zsh.enable;
    enableBashIntegration = true;
    extraOptions = ["-l" "--icons" "--git" "-a"];
  };

  # --- bat with theme-aware syntax highlighting ------------------------------
  programs.bat = {
    enable = true;
    config.theme = theme.batThemeName;
  };

  # --- btop with theme-aware color scheme -----------------------------------
  programs.btop = {
    enable = true;
    settings.color_theme = theme.btopThemeName;
  };

  # --- direnv with nix-direnv for fast persistent dev shells ----------------
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  # --- nix-index: file database for nixpkgs (nix-locate) -------------------
  programs.nix-index = {
    enable = true;
    enableZshIntegration = true;
  };

  # --- lazygit with palette-based theming ------------------------------------
  programs.lazygit = {
    enable = true;
    settings.gui.theme = {
      activeBorderColor = [palette.green "bold"];
      inactiveBorderColor = [palette.comment];
      optionsTextColor = [palette.cyan];
      selectedLineBgColor = [palette.selection];
      cherryPickedCommitBgColor = [palette.purple];
      cherryPickedCommitFgColor = [palette.fg];
      unstagedChangesColor = [palette.red];
      defaultFgColor = [palette.fg];
    };
  };

  # --- dircolors: themed ls colors -------------------------------------------
  programs.dircolors = {
    enable = true;
    enableZshIntegration = true;
  };

  # --- Midnight Commander with theme-aware skin ------------------------------
  # Dracula uses the official 256-color skin; other themes fall back to the
  # built-in dark skin (which inherits terminal colors from Ghostty).
  programs.mc = {
    enable = true;
    settings.Midnight-Commander.skin =
      if theme.mcSkin != null
      then "current-theme"
      else "dark";
  };
  xdg.dataFile."mc/skins/current-theme.ini" = lib.mkIf (theme.mcSkin != null) {
    text = theme.mcSkin;
  };

  # --- Yazi file manager with palette-aware Dracula theme --------------------
  programs.yazi = {
    enable = true;
    enableZshIntegration = true; # creates `y` shell function (cd on quit)
    shellWrapperName = "y";
    theme = {
      mgr = {
        cwd = {fg = palette.cyan;};
        find_keyword = {fg = palette.yellow; bold = true; italic = true; underline = true;};
        find_position = {fg = palette.pink; bg = "reset"; bold = true; italic = true;};
        marker_copied = {fg = palette.green; bg = palette.green;};
        marker_cut = {fg = palette.red; bg = palette.red;};
        marker_marked = {fg = palette.cyan; bg = palette.cyan;};
        marker_selected = {fg = palette.yellow; bg = palette.yellow;};
        count_copied = {fg = palette.bg; bg = palette.green;};
        count_cut = {fg = palette.bg; bg = palette.red;};
        count_selected = {fg = palette.bg; bg = palette.yellow;};
        border_symbol = "│";
        border_style = {fg = palette.comment;};
      };
      tabs = {
        active = {fg = palette.bg; bg = palette.purple; bold = true;};
        inactive = {fg = palette.purple; bg = palette.selection;};
      };
      mode = {
        normal_main = {fg = palette.bg; bg = palette.purple; bold = true;};
        normal_alt = {fg = palette.purple; bg = palette.selection;};
        select_main = {fg = palette.bg; bg = palette.cyan; bold = true;};
        select_alt = {fg = palette.cyan; bg = palette.selection;};
        unset_main = {fg = palette.bg; bg = palette.orange; bold = true;};
        unset_alt = {fg = palette.orange; bg = palette.selection;};
      };
      status = {
        perm_sep = {fg = palette.comment;};
        perm_type = {fg = palette.purple;};
        perm_read = {fg = palette.yellow;};
        perm_write = {fg = palette.red;};
        perm_exec = {fg = palette.green;};
        progress_label = {fg = palette.fg; bold = true;};
        progress_normal = {fg = palette.green; bg = palette.comment;};
        progress_error = {fg = palette.yellow; bg = palette.red;};
      };
      pick = {
        border = {fg = palette.purple;};
        active = {fg = palette.pink; bold = true;};
        inactive = {};
      };
      input = {
        border = {fg = palette.purple;};
        title = {};
        value = {};
        selected = {reversed = true;};
      };
      cmp = {
        border = {fg = palette.purple;};
      };
      tasks = {
        border = {fg = palette.purple;};
        title = {};
        hovered = {fg = palette.pink; bold = true;};
      };
      which = {
        mask = {bg = palette.selection;};
        cand = {fg = palette.cyan;};
        rest = {fg = palette.comment;};
        desc = {fg = palette.pink;};
        separator = "  ";
        separator_style = {fg = palette.comment;};
      };
      help = {
        on = {fg = palette.cyan;};
        run = {fg = palette.pink;};
        hovered = {reversed = true; bold = true;};
        footer = {fg = palette.selection; bg = palette.fg;};
      };
      spot = {
        border = {fg = palette.purple;};
        title = {fg = palette.purple;};
        tbl_col = {fg = palette.cyan;};
        tbl_cell = {fg = palette.pink; bg = palette.comment;};
      };
      notify = {
        title_info = {fg = palette.green;};
        title_warn = {fg = palette.yellow;};
        title_error = {fg = palette.red;};
      };
      filetype.rules = [
        {mime = "image/*"; fg = palette.cyan;}
        {mime = "{audio,video}/*"; fg = palette.yellow;}
        {mime = "application/{zip,rar,7z*,tar,gzip,xz,zstd,bzip*,lzma,compress,archive,cpio,arj,xar,ms-cab*}"; fg = palette.pink;}
        {mime = "application/{pdf,doc,rtf}"; fg = palette.green;}
        {mime = "vfs/{absent,stale}"; fg = palette.comment;}
        {url = "*"; fg = palette.fg;}
        {url = "*/"; fg = palette.purple;}
      ];
    };
    settings = {
      preview = {
        max_width = 1920;
        max_height = 1080;
      };
    };
  };

  # --- Pueue task queue daemon (systemd — Linux only) -------------------------
  services.pueue = lib.mkIf pkgs.stdenv.isLinux {
    enable = true;
    settings = {
      shared = {
        default_parallel_tasks = 2;
      };
    };
  };

  # --- Amfora Gemini browser with palette-aware theme -------------------------
  xdg.configFile."amfora/config.toml".text = ''
    [theme]
    bg = "${palette.bg}"
    tab_num = "${palette.purple}"
    tab_divider = "${palette.fg}"
    bottombar_label = "${palette.purple}"
    bottombar_text = "${palette.cyan}"
    bottombar_bg = "${palette.selection}"
    scrollbar = "${palette.selection}"

    hdg_1 = "${palette.purple}"
    hdg_2 = "${palette.purple}"
    hdg_3 = "${palette.purple}"
    amfora_link = "${palette.pink}"
    foreign_link = "${palette.orange}"
    link_number = "${palette.cyan}"
    regular_text = "${palette.fg}"
    quote_text = "${palette.yellow}"
    preformatted_text = "${palette.orange}"
    list_text = "${palette.fg}"

    btn_bg = "${palette.selection}"
    btn_text = "${palette.fg}"

    dl_choice_modal_bg = "${palette.comment}"
    dl_choice_modal_text = "${palette.fg}"
    dl_modal_bg = "${palette.comment}"
    dl_modal_text = "${palette.fg}"
    info_modal_bg = "${palette.comment}"
    info_modal_text = "${palette.fg}"
    error_modal_bg = "${palette.red}"
    error_modal_text = "${palette.fg}"
    yesno_modal_bg = "${palette.comment}"
    yesno_modal_text = "${palette.fg}"
    tofu_modal_bg = "${palette.comment}"
    tofu_modal_text = "${palette.fg}"
    subscription_modal_bg = "${palette.comment}"
    subscription_modal_text = "${palette.fg}"

    input_modal_bg = "${palette.comment}"
    input_modal_text = "${palette.fg}"
    input_modal_field_bg = "${palette.selection}"
    input_modal_field_text = "${palette.fg}"

    bkmk_modal_bg = "${palette.comment}"
    bkmk_modal_text = "${palette.fg}"
    bkmk_modal_label = "${palette.fg}"
    bkmk_modal_field_bg = "${palette.selection}"
    bkmk_modal_field_text = "${palette.fg}"
  '';

  # --- Common CLI Tools -----------------------------------------------------
  home.packages = with pkgs; [
    coreutils
    fd
    file # File type detection (used by AI agents and scripts)
    gcc
    jq
    unixtools.xxd # Hex dump tool (used by AI agents and scripts)
    unzip
    wget # HTTP fetcher (some tools/agents expect wget alongside curl)
    zip

    # Modern CLI replacements (aliased in zsh.nix)
    # btop is managed via programs.btop above
    doggo # DNS lookup (aliased: dig → doggo)
    duf # Disk usage/free (aliased: df → duf)
    dust # Disk usage (aliased: du → dust)
    prettyping # Prettier ping (aliased: ping → prettyping)
    procs # Process viewer (aliased: ps → procs)
    viddy # Modern watch (aliased: watch → viddy)
    xh # HTTP client (aliased: http → xh)

    # Enhanced tools (not aliased -- use directly)
    bandwhich # Network bandwidth per process: sudo bandwhich
    difftastic # Syntax-aware diff: difft file1 file2
    glow # Render markdown in terminal: glow README.md (aliased: md)
    hyperfine # Benchmark commands: hyperfine 'cmd1' 'cmd2' (aliased: bench)
    # lazygit is managed via programs.lazygit above
    lazydocker # Docker TUI: lazydocker (aliased: ld)
    # mc is managed via programs.mc above
    ncdu # Interactive disk usage: ncdu /path
    ripgrep # Fast grep (aliased: grep → rg)
    tailscaleCli # Tailscale CLI; on macOS this wraps the standalone app bundle
    go-task # Taskfile runner: task, task --list
    tealdeer # Fast tldr client: tldr tar
    tokei # Lines of code counter: tokei . (aliased: loc)
    restic # Backups: restic init, restic backup, restic snapshots

    # --- New modern CLI tools -------------------------------------------------
    choose # Human-friendly cut/awk: docker ps | choose 0 3
    entr # Run commands on file change: ls *.nix | entr nix flake check
    fx # Interactive JSON viewer: fx data.json (aliased: json)
    gum # Interactive shell scripts: gum choose, gum input, gum spin
    just # Task runner: just switch, just check
    moreutils # sponge, ts, parallel, vidir, errno, ifdata
    nix-diff # Diff Nix derivations: nix-diff /nix/store/a /nix/store/b
    nix-tree # TUI to explore Nix store closures: nix-tree /nix/store/path
    nurl # Generate Nix fetcher calls from URLs: nurl https://github.com/foo/bar v1.0
    nvd # Nix package version diff: nvd diff /run/current-system result
    ouch # Universal compress/decompress: ouch d file.tar.gz, ouch c dir out.zip
    sd # Intuitive sed alternative: sd 'old' 'new' file
    sshs # TUI SSH connection manager: sshs
    watchexec # Run commands on file change (advanced): watchexec -e nix -- nix flake check
    comma # Run nixpkgs binaries without installing: , cowsay hello

    # --- Terminal image/media viewers -----------------------------------------
    chafa # Terminal image viewer (Sixel/Kitty): chafa image.png (aliased: img)
    timg # Terminal image/video viewer: timg image.png, timg video.mp4 (aliased: vid)

    # --- CLI browsers ---------------------------------------------------------
    w3m # Text-mode HTTP browser with image support: w3m https://example.com (aliased: web)
    lynx # Text-mode HTTP browser: lynx https://example.com
    amfora # Gemini protocol browser with Dracula theme: amfora (aliased: gemini)
    bombadillo # Gopher + Gemini + Finger browser: bombadillo (aliased: gopher)

    # --- Yazi preview dependencies --------------------------------------------
    ffmpegthumbnailer # Video thumbnails for yazi preview
    poppler-utils # PDF preview (pdftoppm) for yazi

    # Zsh plugins (nix-zsh-completions stays as a package; others sourced via programs.zsh.plugins in zsh.nix)
    nix-zsh-completions # Tab completion for nix commands
  ];
}
