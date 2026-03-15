{pkgs, ...}: {
  imports = [
    ../common/homebrew.nix
  ];

  networking = {
    hostName = "macmini";
    computerName = "macmini";
    localHostName = "macmini";
  };

  time.timeZone = "America/New_York";

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    git
  ];

  programs.zsh.enable = true;

  system.defaults = {
    NSGlobalDomain = {
      AppleShowAllExtensions = true;
      InitialKeyRepeat = 25;
      KeyRepeat = 2;
    };
    dock = {
      autohide = true;
      show-recents = false;
      persistent-apps = [];
    };
    finder = {
      FXPreferredViewStyle = "Nlsv";
      ShowStatusBar = true;
      ShowPathbar = true;
    };
  };

  system.stateVersion = 5;
}
