{...}: {
  # Main entrypoint for the iceman nix-darwin configuration.
  imports = [
    ../common/default.nix
    ./configuration.nix
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";
}
