# Karabiner-Elements is installed via Homebrew cask (homebrew.nix).
# This module ensures its non-privileged agents start at login.
# The agents app registers the grabber, session monitor, menu bar icon, etc.
{...}: {
  launchd.agents.karabiner-elements = {
    serviceConfig = {
      Label = "org.nixos.karabiner-elements";
      ProgramArguments = [
        "/usr/bin/open"
        "-a"
        "/Library/Application Support/org.pqrs/Karabiner-Elements/Karabiner-Elements Non-Privileged Agents v2.app"
      ];
      RunAtLoad = true;
      LaunchOnlyOnce = true;
    };
  };
}
