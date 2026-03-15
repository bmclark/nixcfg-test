# Helper commands for managing this flake across NixOS, nix-darwin, and home-manager.
# Requires `just` (install with `nix-shell -p just` or add to your system packages).
# Recipes are grouped by platform and workflow for quick navigation.

# --------------------------------------------------
# Default
default:
    @just --list

# --------------------------------------------------
# NixOS Commands
nixos-switch-host SYSTEM:
    @sudo nixos-rebuild switch --flake .#{{SYSTEM}} --impure

nixos-switch:
    @just nixos-switch-host carbon

nixos-test:
    @sudo nixos-rebuild test --flake .#carbon --impure

nixos-boot:
    @sudo nixos-rebuild boot --flake .#carbon --impure

nixos-build SYSTEM:
    @nixos-rebuild build --flake .#{{SYSTEM}} --impure

deploy-to HOST SYSTEM:
    @nixos-rebuild switch --flake .#{{SYSTEM}} --target-host {{HOST}} --use-remote-sudo

deploy SYSTEM:
    @just deploy-to {{SYSTEM}} {{SYSTEM}}

# --------------------------------------------------
# Darwin Commands
darwin-switch-host SYSTEM:
    @darwin-rebuild switch --flake .#{{SYSTEM}} --impure

darwin-switch:
    @just darwin-switch-host macmini

darwin-test:
    @darwin-rebuild check --flake .#macmini --impure

darwin-build:
    @darwin-rebuild build --flake .#macmini --impure

# --------------------------------------------------
# Home Manager Commands
# Provide the host suffix used in flake attributes (e.g., carbon -> .#bclark@carbon).
# Useful for quick user-space tweaks without a full system rebuild.
home-switch HOST:
    @home-manager switch --flake .#bclark@{{HOST}}

home-switch-local:
    @HOST=${HOST:-$(hostname -s | tr '[:upper:]' '[:lower:]' | tr -cd '[:alnum:]')} ; \
    just home-switch $HOST

home-build HOST:
    @home-manager build --flake .#bclark@{{HOST}}

# --------------------------------------------------
# Cross-Platform Commands
switch:
    @if [ "$(uname -s)" = "Darwin" ]; then \
        just darwin-switch; \
    else \
        just nixos-switch; \
    fi

test:
    @if [ "$(uname -s)" = "Darwin" ]; then \
        just darwin-test; \
    else \
        just nixos-test; \
    fi

build-all:
    @just nixos-build carbon
    @just darwin-build

# --------------------------------------------------
# Update Workflow
update:
    @nix flake update

update-input INPUT:
    @nix flake lock --update-input {{INPUT}}

# Updates flake, rebuilds both systems, and switches current machine; cross-host switching requires remote access setup.
update-all: update
    @just build-all
    @just switch

# --------------------------------------------------
# Maintenance
gc:
    @nix-collect-garbage --delete-older-than 7d

gc-old:
    @nix-collect-garbage --delete-older-than 30d

gc-all:
    @sudo nix-collect-garbage -d

optimize:
    @nix-store --optimize

clean:
    @just gc
    @just optimize

# --------------------------------------------------
# Flake Utilities
check:
    @nix flake check

show:
    @nix flake show

# --------------------------------------------------
# Git Workflow
commit MESSAGE:
    @git add .
    @git commit -m "{{MESSAGE}}"
    @git push

update-and-commit MESSAGE: update
    @just commit "{{MESSAGE}}"

deploy-update-commit SYSTEM MESSAGE: (deploy SYSTEM) update
    @just commit "{{MESSAGE}}"

# --------------------------------------------------
# Theme Switching
# Rebuild with a different theme. Available: dracula (default), tokyo-night, synthwave84
# Example: just theme tokyo-night
theme THEME="dracula":
    @NIXCFG_THEME={{THEME}} just switch

# --------------------------------------------------
# Development Environments
dev-shell:
    @nix develop

dev: dev-shell
