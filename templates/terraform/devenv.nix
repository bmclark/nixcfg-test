# Terraform/OpenTofu IaC development environment.
# Run `devenv shell` to enter, or use direnv for auto-activation.
{pkgs, ...}: {
  packages = with pkgs; [
    opentofu
    terraform-ls
    tflint
    terragrunt
    tfsec
    trivy
    awscli2
    sops
    age
  ];

  devcontainer.enable = true;
}
