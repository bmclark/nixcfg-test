# TypeScript/Node.js development environment with pnpm.
# Run `devenv shell` to enter, or use direnv for auto-activation.
{pkgs, ...}: {
  languages.javascript = {
    enable = true;
    pnpm.enable = true;
  };

  languages.typescript.enable = true;

  packages = with pkgs; [
    nodePackages.prettier
    nodePackages.typescript-language-server
  ];

  devcontainer.enable = true;
}
