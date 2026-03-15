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
      AppleInterfaceStyle = "Dark";
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
      InitialKeyRepeat = 15;
      KeyRepeat = 2;
    };
    dock = {
      autohide = true;
      show-recents = false;
      persistent-apps = [];
      mru-spaces = false;
      launchanim = false;
      tilesize = 48;
    };
    finder = {
      FXPreferredViewStyle = "Nlsv";
      ShowStatusBar = true;
      ShowPathbar = true;
      AppleShowAllExtensions = true;
      _FXShowPosixPathInTitle = true;
    };
    trackpad = {
      Clicking = true;
      TrackpadRightClick = true;
    };
    screencapture = {
      location = "~/Pictures/Screenshots";
      type = "png";
    };
    alf = {
      globalstate = 1;
      allowsignedenabled = 1;
    };
  };

  system.stateVersion = 5;
}
