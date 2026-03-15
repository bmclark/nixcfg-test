# Rust development environment with cargo, clippy, and rust-analyzer.
# Run `devenv shell` to enter, or use direnv for auto-activation.
{pkgs, ...}: {
  languages.rust.enable = true;

  packages = with pkgs; [
    pkg-config
    openssl
  ];

  devcontainer.enable = true;
}
