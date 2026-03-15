{...}: {
  # Main entrypoint for the macmini nix-darwin configuration.
  imports = [
    ../common/default.nix
    ./configuration.nix
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";
}
