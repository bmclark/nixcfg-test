# AltTab is installed via Homebrew cask (homebrew.nix).
# This module ensures it starts at login so Alt+Tab app switching works immediately.
{...}: {
  launchd.agents.alttab = {
    serviceConfig = {
      Label = "org.nixos.alttab";
      ProgramArguments = [
        "/usr/bin/open"
        "-a"
        "/Applications/AltTab.app"
      ];
      RunAtLoad = true;
      LaunchOnlyOnce = true;
    };
  };
}
