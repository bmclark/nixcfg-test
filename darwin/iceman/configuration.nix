{pkgs, lib, ...}: {
  imports = [
    ../common/homebrew.nix
  ];

  networking = {
    hostName = "iceman";
    computerName = "iceman";
    localHostName = "iceman";
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
      TrackpadThreeFingerVertSwipeGesture = 0;
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
    WindowManager = {
      GloballyEnabled = false; # Disable Stage Manager
    };
    CustomUserPreferences = {
      "com.apple.screensaver" = {
        idleTime = 900;
      };
      "com.apple.desktopservices" = {
        DSDontWriteNetworkStores = true;
        DSDontWriteUSBStores = true;
      };
      # Disable Mission Control keyboard shortcuts (Aerospace owns window management)
      "com.apple.symbolichotkeys" = {
        AppleSymbolicHotKeys = {
          # Mission Control (Ctrl+Up / F3)
          "32" = { enabled = false; };
          "34" = { enabled = false; };
          # Application Windows (Ctrl+Down)
          "33" = { enabled = false; };
          "35" = { enabled = false; };
          # Move left a space (Ctrl+Left / fn variant)
          "79" = { enabled = false; };
          "80" = { enabled = false; };
          # Move right a space (Ctrl+Right / fn variant)
          "81" = { enabled = false; };
          "82" = { enabled = false; };
          # Switch to Desktop 1-6 (Ctrl+1 through Ctrl+6)
          "118" = { enabled = false; };
          "119" = { enabled = false; };
          "120" = { enabled = false; };
          "121" = { enabled = false; };
          "122" = { enabled = false; };
          "123" = { enabled = false; };
        };
      };
    };
  };

  system.startup.chime = false;

  power = {
    restartAfterPowerFailure = true;
    restartAfterFreeze = true;
    sleep = {
      computer = 0;  # Never sleep (always-on Mac Mini)
      display = 60;  # Display sleeps after 60 minutes
      harddisk = 0;  # Never spin down
    };
  };

  system.activationScripts.postActivation.text = lib.mkAfter ''
    echo "--- FileVault status ---" >&2
    /usr/bin/fdesetup status >&2
    echo "------------------------" >&2
  '';

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
