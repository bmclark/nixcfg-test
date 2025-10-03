
# List available commands
default:
    @just --list

# Deploy system configuration
deploy SYSTEM:
    nixos-rebuild switch --flake .#{{SYSTEM}} --target-host {{SYSTEM}} --use-remote-sudo

# Update flake
update:
    nix flake update

# Commit and push changes
commit MESSAGE:
    git add .
    git commit -m "{{MESSAGE}}"
    git push

# Update, commit, and push changes
update-and-commit MESSAGE: update
    @just commit "{{MESSAGE}}"

# Deploy, update, commit, and push changes
deploy-update-commit SYSTEM MESSAGE: (deploy SYSTEM) update
    @just commit "{{MESSAGE}}"

# Check flake
check:
    nix flake check

# Show flake info
show:
    nix flake show

# Build system configuration
build SYSTEM:
    nixos-rebuild build --flake .#{{SYSTEM}}

# Enter a development shell
dev-shell:
    nix develop
