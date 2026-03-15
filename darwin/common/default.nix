{
  pkgs,
  lib,
  inputs,
  outputs,
  ...
}: {
  imports = [
    ./users
    ./karabiner.nix
  ];

  nixpkgs = {
    config.allowUnfree = true;
  };

  nix = let
    flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
  in {
    settings = {
      experimental-features = "nix-command flakes";
      trusted-users = [
        "root"
        "bclark"
      ];
    };
    gc = {
      automatic = true;
      options = "--delete-older-than 30d";
    };
    optimise.automatic = true;
    registry = lib.mapAttrs (_: flake: {inherit flake;}) flakeInputs;
    nixPath =
      ["/etc/nix/path"]
      ++ lib.mapAttrsToList (flakeName: _: "${flakeName}=flake:${flakeName}") flakeInputs;
  };

  programs.zsh.enable = true;
}
