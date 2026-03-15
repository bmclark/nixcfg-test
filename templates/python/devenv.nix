# Python development environment with uv, ruff, and pyright.
# Run `devenv shell` to enter, or use direnv for auto-activation.
{pkgs, ...}: {
  languages.python = {
    enable = true;
    uv = {
      enable = true;
      sync.enable = true;
    };
  };

  packages = with pkgs; [
    ruff
    pyright
  ];

  devcontainer.enable = true;
}
