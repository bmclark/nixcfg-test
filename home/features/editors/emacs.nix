{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.editors.emacs;
in {
  options.features.editors.emacs.enable = mkEnableOption "enable vanilla Emacs";

  config = mkIf cfg.enable {
    programs.emacs = {
      enable = true;
      # Packages that need native compilation go here (built in Nix sandbox).
      # Everything else is managed via MELPA in init.el.
      extraPackages = epkgs: [
        epkgs.vterm # native module — can't compile from MELPA (needs glib headers)
        epkgs.treesit-grammars.with-all-grammars # tree-sitter grammars for *-ts-mode
        epkgs.treesit-auto # auto-remap to tree-sitter modes when grammars available
      ];
    };

    home.file.".emacs.d/init.el".source = ./init.el;
    home.file.".config/eca/config.json".source = ./eca-config.json;

    home.sessionVariables = {
      EDITOR = "emacsclient -t -a ''";
      VISUAL = "emacsclient -c -a ''";
    };

    # LSP servers and tools needed by init.el that aren't in development/default.nix.
    # Already available via development module: nil, alejandra, shellcheck,
    # terraform-ls, ruff, nodejs, typescript.
    home.packages = with pkgs; [
      # LSP servers (supplements development/default.nix which has nil, terraform-ls)
      pyright # Python LSP (type checking + intellisense)
      typescript-language-server # TS/JS LSP
      yaml-language-server # YAML LSP
      gopls # Go LSP
      rust-analyzer # Rust LSP
      dockerfile-language-server # Dockerfile LSP
      bash-language-server # Bash/Shell LSP
      marksman # Markdown LSP
      ltex-ls-plus # Grammar/spell checking LSP for prose

      # Formatters used by LSP
      shfmt # Shell formatter
      gotools # goimports etc.

      # Writing / export
      pandoc # Universal document converter (org → EPUB, DOCX, PDF, Hugo)
      texliveSmall # LaTeX for PDF export (org → LaTeX → PDF)

      # Spell checking (jinx backend)
      enchant_2 # Meta spell-check library (runtime)
      hunspellDicts.en_US # English dictionary
      pkg-config # Needed by jinx native module compilation
    ];

    # Emacs daemon: runs as a systemd user service so emacsclient starts instantly.
    # Use `emacsclient -c` for GUI frames, `emacsclient -t` for terminal.
    services.emacs = {
      enable = true;
      defaultEditor = false;
      client.enable = true;
      startWithUserSession = "graphical";
    };

    # Jinx spell checker compiles a native module on first use and needs
    # enchant-2.pc to find headers/libs via pkg-config.
    # Set PKG_CONFIG_PATH in both shell sessions and the systemd Emacs daemon.
    home.sessionVariablesExtra = ''
      export PKG_CONFIG_PATH="${pkgs.enchant_2.dev}/lib/pkgconfig''${PKG_CONFIG_PATH:+:$PKG_CONFIG_PATH}"
    '';
    systemd.user.sessionVariables.PKG_CONFIG_PATH = "${pkgs.enchant_2.dev}/lib/pkgconfig";
  };
}
