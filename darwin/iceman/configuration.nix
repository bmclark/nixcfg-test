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
      AppleShowAllFiles = true;
      "com.apple.swipescrolldirection" = false; # Disable "natural" scrolling
      _HIHideMenuBar = false;

    };
    dock = {
      autohide = true;
      show-recents = false;
      persistent-apps = [
        "/System/Library/CoreServices/Finder.app"
        "/Applications/cmux.app"
        "/Applications/Visual Studio Code.app"
        "/Applications/Google Chrome.app"
        "/Applications/Claude.app"
        "/Applications/ChatGPT.app"
        "/System/Applications/Messages.app"
        "/System/Applications/Mail.app"
        "/System/Applications/Calendar.app"
        "/System/Applications/Notes.app"
        "/Applications/Spotify.app"
        "/Applications/Bitwarden.app"
        "/System/Applications/System Settings.app"
      ];
      mru-spaces = false;
      launchanim = false;
      tilesize = 48;
      mineffect = "scale";
      minimize-to-application = true;
      show-process-indicators = true;
      expose-animation-duration = 0.1; # Faster Mission Control animation
      # Hot corners disabled (1=disabled)
      wvous-tl-corner = 1;
      wvous-tr-corner = 1;
      wvous-bl-corner = 1;
      wvous-br-corner = 1;
    };
    finder = {
      FXPreferredViewStyle = "Nlsv";
      ShowStatusBar = true;
      ShowPathbar = true;
      AppleShowAllExtensions = true;
      _FXShowPosixPathInTitle = true;
      NewWindowTarget = "Home";
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
      TrackpadThreeFingerDrag = true;
    };
    screencapture = {
      location = "~/Pictures/Screenshots";
      type = "png";
      target = "clipboard";
      disable-shadow = true;
      show-thumbnail = false;
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
    loginwindow = {
      GuestEnabled = false;
    };
    SoftwareUpdate = {
      AutomaticallyInstallMacOSUpdates = true;
    };
    spaces = {
      spans-displays = false; # Independent spaces per display
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
          "32" = { enabled = false; value = { parameters = [65535 65535 0]; type = "standard"; }; };
          "34" = { enabled = false; value = { parameters = [65535 65535 0]; type = "standard"; }; };
          # Application Windows (Ctrl+Down)
          "33" = { enabled = false; value = { parameters = [65535 65535 0]; type = "standard"; }; };
          "35" = { enabled = false; value = { parameters = [65535 65535 0]; type = "standard"; }; };
          # Move left a space (Ctrl+Left / fn variant)
          "79" = { enabled = false; value = { parameters = [65535 65535 0]; type = "standard"; }; };
          "80" = { enabled = false; value = { parameters = [65535 65535 0]; type = "standard"; }; };
          # Move right a space (Ctrl+Right / fn variant)
          "81" = { enabled = false; value = { parameters = [65535 65535 0]; type = "standard"; }; };
          "82" = { enabled = false; value = { parameters = [65535 65535 0]; type = "standard"; }; };
          # Switch to Desktop 1-6 (Ctrl+1 through Ctrl+6)
          "118" = { enabled = false; value = { parameters = [65535 65535 0]; type = "standard"; }; };
          "119" = { enabled = false; value = { parameters = [65535 65535 0]; type = "standard"; }; };
          "120" = { enabled = false; value = { parameters = [65535 65535 0]; type = "standard"; }; };
          "121" = { enabled = false; value = { parameters = [65535 65535 0]; type = "standard"; }; };
          "122" = { enabled = false; value = { parameters = [65535 65535 0]; type = "standard"; }; };
          "123" = { enabled = false; value = { parameters = [65535 65535 0]; type = "standard"; }; };
          # Accessibility shortcuts that collide with Hyper+key
          # Full parameter structure required — bare `enabled = false` is ignored by macOS
          "12" = { enabled = false; value = { parameters = [65535 65535 0]; type = "standard"; }; };  # Invert Colors (Cmd+Ctrl+Opt+8)
          "21" = { enabled = false; value = { parameters = [65535 65535 0]; type = "standard"; }; };  # Reverse Black and White (Cmd+Ctrl+Opt+8)
          "25" = { enabled = false; value = { parameters = [65535 65535 0]; type = "standard"; }; };  # Increase Contrast (Cmd+Ctrl+Opt+.)
          "26" = { enabled = false; value = { parameters = [65535 65535 0]; type = "standard"; }; };  # Decrease Contrast (Cmd+Ctrl+Opt+,)
          "15" = { enabled = false; value = { parameters = [65535 65535 0]; type = "standard"; }; };  # Zoom Toggle (Cmd+Opt+8)
          "17" = { enabled = false; value = { parameters = [65535 65535 0]; type = "standard"; }; };  # Zoom In (Cmd+Opt+=)
          "19" = { enabled = false; value = { parameters = [65535 65535 0]; type = "standard"; }; };  # Zoom Out (Cmd+Opt+-)
        };
      };
    };
  };

  system.startup.chime = false;

  power = {
    restartAfterPowerFailure = true;
    restartAfterFreeze = true;
    sleep = {
      computer = "never";  # Always-on Mac Mini
      display = "never";   # Never sleep display — KVM built into monitor
      harddisk = "never";  # Never spin down
      allowSleepByPowerButton = false;  # Prevent KVM from triggering sleep
    };
  };

  system.activationScripts.postActivation.text = lib.mkAfter ''
    echo "--- FileVault status ---" >&2
    /usr/bin/fdesetup status >&2
    echo "------------------------" >&2

    # Disable Power Nap — not needed on always-on Mac Mini
    /usr/bin/pmset -a powernap 0

    # Enable Night Shift (sunset to sunrise)
    # Use PlistBuddy because `defaults` cannot nest dicts.
    /usr/libexec/PlistBuddy \
      -c "Delete :CBBlueReductionStatus" \
      -c "Add :CBBlueReductionStatus dict" \
      -c "Add :CBBlueReductionStatus:AutoBlueReductionEnabled bool true" \
      -c "Add :CBBlueReductionStatus:BlueLightReductionSchedule dict" \
      -c "Add :CBBlueReductionStatus:BlueLightReductionSchedule:DayStartHour integer 7" \
      -c "Add :CBBlueReductionStatus:BlueLightReductionSchedule:DayStartMinute integer 0" \
      -c "Add :CBBlueReductionStatus:BlueLightReductionSchedule:NightStartHour integer 22" \
      -c "Add :CBBlueReductionStatus:BlueLightReductionSchedule:NightStartMinute integer 0" \
      /var/root/Library/Preferences/com.apple.CoreBrightness.plist 2>/dev/null || true
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
