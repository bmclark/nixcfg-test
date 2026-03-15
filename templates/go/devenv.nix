# Go development environment with gopls, golangci-lint, and delve.
# Run `devenv shell` to enter, or use direnv for auto-activation.
{pkgs, ...}: {
  languages.go.enable = true;

  packages = with pkgs; [
    golangci-lint
    delve
    gotools
  ];

  devcontainer.enable = true;
}
