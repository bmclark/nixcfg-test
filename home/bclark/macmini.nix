# macOS Mac Mini (macmini) -- aarch64-darwin with nix-darwin.
{pkgs, ...}: {
  imports = [
    ../common/default.nix
    ./dotfiles
    ../features/cli
    ../features/development
    ../features/desktop
    ../features/editors
    ./home.nix
  ];

  features = {
    cli = {
      zsh.enable = true;
      fzf.enable = true;
      ghostty.enable = true;
      tmux.enable = true;
      atuin.enable = true;
    };
    development = {
      git.enable = true;
      vscode.enable = true;
    };
    desktop = {
      fonts.enable = true;
      firefox.enable = true;
      chromium.enable = true;
      karabiner.enable = true;
    };
    editors = {
      emacs.enable = true;
    };
  };
}
