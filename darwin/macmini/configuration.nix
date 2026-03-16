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
      # Sound
      "com.apple.sound.beep.feedback" = 0;
      "com.apple.sound.beep.volume" = 0.0;
      # UX Polish
      NSTableViewDefaultSizeMode = 2;
      AppleShowScrollBars = "Always";
      NSNavPanelExpandedStateForSaveMode = true;
      NSNavPanelExpandedStateForSaveMode2 = true;
      PMPrintingExpandedStateForPrint = true;
      PMPrintingExpandedStateForPrint2 = true;
    };
    dock = {
      autohide = true;
      show-recents = false;
      persistent-apps = [];
      mru-spaces = false;
      launchanim = false;
      tilesize = 48;
      mineffect = "scale";
      minimize-to-application = true;
      # Hot corners (0=disabled, 4=desktop, 10=display sleep, 13=lock screen, 14=quick note)
      wvous-tl-corner = 13; # Lock Screen
      wvous-tr-corner = 14; # Quick Note
      wvous-bl-corner = 4;  # Desktop
      wvous-br-corner = 10; # Display Sleep
    };
    finder = {
      FXPreferredViewStyle = "Nlsv";
      ShowStatusBar = true;
      ShowPathbar = true;
      AppleShowAllExtensions = true;
      _FXShowPosixPathInTitle = true;
      NewWindowTarget = "PfHm"; # New windows open to home
      FXEnableExtensionChangeWarning = false;
      ShowExternalHardDrivesOnDesktop = true;
      ShowRemovableMediaOnDesktop = true;
      ShowMountedServersOnDesktop = true;
      FXDefaultSearchScope = "SCcf"; # Search current folder by default
      _FXSortFoldersFirst = true;
    };
    trackpad = {
      Clicking = true;
      TrackpadRightClick = true;
    };
    screencapture = {
      location = "~/Pictures/Screenshots";
      type = "png";
    };
    # --- Menu Bar / Control Center ---
    menuExtraClock = {
      Show24Hour = false;
      ShowAMPM = true;
      ShowDate = 1; # 0 = when space allows, 1 = always, 2 = never
      ShowDayOfWeek = true;
    };
    controlcenter = {
      BatteryShowPercentage = true;
      Bluetooth = true;
      Sound = true;
    };
    # --- Login & Security ---
    screensaver = {
      askForPassword = true;
      askForPasswordDelay = 60;
    };
    LaunchServices = {
      LSQuarantine = false;
    };
    CustomUserPreferences = {
      "com.apple.screensaver" = {
        idleTime = 900;
      };
    };
  };

  system.startup.chime = false;

  networking.applicationFirewall = {
    enable = true;
    allowSigned = true;
  };

  remoteAccess.screenSharing = {
    enable = true;
    allowedUsers = ["bclark"];
  };

  system.primaryUser = "bclark";
  system.stateVersion = 5;
}
