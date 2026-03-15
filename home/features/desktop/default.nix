# Desktop modules: window manager, browsers, fonts, and input remapping.
{pkgs, ...}: {
  imports = [
    ./fonts.nix
    ./hyprland.nix
    ./wayland.nix
    ./firefox.nix
    ./chromium.nix
    ./karabiner.nix
  ];

  home.packages = with pkgs; [tree];
}
