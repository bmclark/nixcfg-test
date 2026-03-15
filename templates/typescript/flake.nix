{
  description = "TypeScript/Node.js development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    devenv.url = "github:cachix/devenv";
  };

  nixConfig = {
    extra-trusted-public-keys = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    extra-substituters = "https://devenv.cachix.org";
  };

  outputs = {
    nixpkgs,
    devenv,
    ...
  } @ inputs: let
    forEachSystem = nixpkgs.lib.genAttrs [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
  in {
    packages = forEachSystem (system: {
      devenv-up = inputs.self.devShells.${system}.default.config.procfileScript;
    });

    devShells = forEachSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      default = devenv.lib.mkShell {
        inherit inputs pkgs;
        modules = [./devenv.nix];
      };
    });
  };
}
