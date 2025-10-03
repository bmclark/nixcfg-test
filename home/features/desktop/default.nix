{pkgs, ...}: {
  imports = [
    ./fonts.nix
    ./hyprland.nix
    ./wayland.nix
    ./firefox.nix
  ];

  home.packages = with pkgs; [
    tree
  ];
}
