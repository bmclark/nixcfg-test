{...}: {
  # Entry point for the maverick NixOS configuration.
  imports = [
    ./configuration.nix
    ./hardware-configuration.nix
    ../common/default.nix
  ];
}
