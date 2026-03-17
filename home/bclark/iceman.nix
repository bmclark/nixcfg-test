# macOS Mac Mini (iceman) -- aarch64-darwin with nix-darwin.
{
  pkgs,
  config,
  ...
}: {
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
      aerospace.enable = true;
    };
    editors = {
      emacs.enable = true;
    };
  };

  # Weekly flake update timer (Sunday 9am) -- mirrors maverick's systemd timer.
  launchd.agents.flake-update = {
    enable = true;
    config = {
      Label = "org.nixos.flake-update";
      ProgramArguments = [
        "${pkgs.nix}/bin/nix"
        "flake"
        "update"
        "--flake"
        "${config.home.homeDirectory}/nixcfg"
      ];
      StartCalendarInterval = [
        {
          Weekday = 7; # Sunday
          Hour = 9;
          Minute = 0;
        }
      ];
      StandardOutPath = "/tmp/flake-update.log";
      StandardErrorPath = "/tmp/flake-update.err";
    };
  };
}
