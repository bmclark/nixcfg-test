# Homebrew on macOS: minimized to only what requires system-level access.
# Karabiner-Elements needs Accessibility + Input Monitoring permissions,
# which makes it unsuitable for pure nixpkgs management.
# Ghostty removed -- installed manually or via nixpkgs config-only approach.
{...}: {
  homebrew = {
    enable = true;
    onActivation.cleanup = "zap";
    taps = [
      "homebrew/cask"
    ];
    casks = [
      "karabiner-elements" # Requires system-level keyboard access
    ];
  };
}
