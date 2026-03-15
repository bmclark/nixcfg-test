{...}: {
  # Entry point for the carbon NixOS configuration.
  imports = [
    ./configuration.nix
    ./hardware-configuration.nix
    ../common/default.nix
  ];
}
