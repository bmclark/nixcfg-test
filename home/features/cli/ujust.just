# Universal host-level justfile for commands that are useful from any directory.

default:
  @just --list

now:
  @date

weather LOCATION="":
  @if [ -n "{{LOCATION}}" ]; then \
    curl -fsSL "wttr.in/{{LOCATION}}"; \
  elif [ -n "$WEATHER_LOCATION" ]; then \
    curl -fsSL "wttr.in/$WEATHER_LOCATION"; \
  else \
    curl -fsSL wttr.in; \
  fi

ip:
  @curl -fsSL ifconfig.me

ports:
  @ss -tulanp

path:
  @printf '%s\n' "$PATH" | tr ":" "\n"

uuid:
  @uuidgen

sha256 FILE:
  @sha256sum {{FILE}}

serve PORT="8000":
  @python3 -m http.server {{PORT}}

user-services:
  @systemctl --user --failed

host-info:
  @bash -eu -c 'host="$(hostname -s)"; os="$(uname -s)"; kernel="$(uname -r)"; uptime_info="$(uptime -p 2>/dev/null | sed "s/^up //")"; if [ -z "$uptime_info" ]; then uptime_info="$(uptime | sed -E "s/^.*up ([^,]+),.*$/\1/")"; fi; shell_name="$(basename "$SHELL")"; if command -v tailscale >/dev/null 2>&1; then tail_state="$(tailscale status --json 2>/dev/null | jq -r ".BackendState // empty" 2>/dev/null || true)"; tail_ip="$(tailscale ip -4 2>/dev/null | head -n1 || true)"; else tail_state="unavailable"; tail_ip=""; fi; if [ -L /run/current-system ]; then generation="$(basename "$(readlink /run/current-system)")"; elif command -v darwin-rebuild >/dev/null 2>&1 && [ -L /nix/var/nix/profiles/system ]; then generation="$(basename "$(readlink /nix/var/nix/profiles/system)")"; else generation="unknown"; fi; if [ -d "$HOME/nixcfg/.git" ]; then if git -C "$HOME/nixcfg" diff --quiet && git -C "$HOME/nixcfg" diff --cached --quiet; then tree_state="clean"; tree_color="2"; else tree_state="dirty"; tree_color="3"; fi; flake_lock="$(date -r "$HOME/nixcfg/flake.lock" "+%Y-%m-%d %H:%M" 2>/dev/null || stat -c "%y" "$HOME/nixcfg/flake.lock" 2>/dev/null || echo unknown)"; else tree_state="unknown"; tree_color="7"; flake_lock="unknown"; fi; if [ -n "$tail_ip" ]; then tail_label="$tail_ip"; elif [ -n "$tail_state" ]; then tail_label="$tail_state"; else tail_label="disconnected"; fi; card="$(printf "Host: %s\nOS: %s\nKernel: %s\nUptime: %s\nShell: %s\nTailscale: %s\nGeneration: %s\nnixcfg tree: %s\nflake.lock: %s" "$host" "$os" "$kernel" "$uptime_info" "$shell_name" "$tail_label" "$generation" "$tree_state" "$flake_lock")"; gum style --border normal --margin "1 0" --padding "1 2" --border-foreground 12 --foreground 15 "$card"'

doctor:
  @bash -eu -c '\
    section() { gum style --bold --foreground 12 "$1"; }; \
    ok() { gum style --foreground 2 "OK  $1"; }; \
    warn() { gum style --foreground 3 "WARN $1"; }; \
    info() { gum style --foreground 7 "$1"; }; \
    echo; section "Host"; \
    just --justfile "$HOME/.config/just/justfile" host-info; \
    echo; section "Services"; \
    failed_services="$(systemctl --user --failed --no-legend 2>/dev/null || true)"; \
    if [ -n "$failed_services" ]; then warn "failed user services detected"; printf "%s\n" "$failed_services"; else ok "no failed user services"; fi; \
    echo; section "Disk"; \
    root_src="$(df --output=source / | tail -n1 | xargs)"; \
    home_src="$(df --output=source "$HOME" | tail -n1 | xargs)"; \
    if [ "$root_src" = "$home_src" ]; then df -h /; else df -h / "$HOME"; fi; \
    echo; section "Tailscale"; \
    if command -v tailscale >/dev/null 2>&1; then \
      tail_json="$(tailscale status --json 2>/dev/null || true)"; \
      tail_state="$(printf "%s" "$tail_json" | jq -r ".BackendState // empty" 2>/dev/null || true)"; \
      tail_ip="$(tailscale ip -4 2>/dev/null | head -n1 || true)"; \
      if [ -n "$tail_ip" ]; then ok "connected ($tail_ip)"; \
      elif [ "$tail_state" = "NeedsLogin" ] || [ "$tail_state" = "Stopped" ]; then warn "not connected ($tail_state)"; \
      elif [ -n "$tail_state" ]; then info "$tail_state"; \
      else warn "status unavailable"; fi; \
    else warn "tailscale cli not installed"; fi; \
    echo; section "GPG"; \
    secret_keys="$(gpg --list-secret-keys --with-colons 2>/dev/null | grep -c "^sec:" || true)"; \
    if [ "$secret_keys" -gt 0 ]; then ok "$secret_keys secret key(s) present"; else warn "no secret keys configured"; fi; \
    echo; section "nix-index"; \
    if [ -e "$HOME/.cache/nix-index/files" ]; then ok "database present"; else warn "database missing; run: nix-index"; fi; \
    echo; section "nixcfg"; \
    if just --justfile "$HOME/nixcfg/justfile" --working-directory "$HOME/nixcfg" check >/tmp/ujust-check.$$ 2>&1; then ok "flake check passed"; \
    else warn "flake check reported issues"; sed -n "1,20p" /tmp/ujust-check.$$; fi; \
    rm -f /tmp/ujust-check.$$ \
  '

tailscale-status:
  @if command -v tailscale >/dev/null 2>&1; then \
    tailscale status; \
  else \
    echo "tailscale cli not installed"; \
    exit 1; \
  fi

tailscale-up:
  @if command -v tailscale >/dev/null 2>&1; then \
    sudo tailscale up; \
  else \
    echo "tailscale cli not installed"; \
    exit 1; \
  fi

tailscale-down:
  @if command -v tailscale >/dev/null 2>&1; then \
    sudo tailscale down; \
  else \
    echo "tailscale cli not installed"; \
    exit 1; \
  fi

nixcfg-check:
  @just --justfile "$HOME/nixcfg/justfile" --working-directory "$HOME/nixcfg" check

nixcfg-update:
  @just --justfile "$HOME/nixcfg/justfile" --working-directory "$HOME/nixcfg" update

nixcfg-switch:
  @just --justfile "$HOME/nixcfg/justfile" --working-directory "$HOME/nixcfg" switch

nixcfg-home-switch:
  @just --justfile "$HOME/nixcfg/justfile" --working-directory "$HOME/nixcfg" home-switch

rebuild:
  @just --justfile "$HOME/.config/just/justfile" nixcfg-switch

home-rebuild:
  @just --justfile "$HOME/.config/just/justfile" nixcfg-home-switch

rollback:
  @if [ "$(uname -s)" = "Darwin" ]; then \
    darwin-rebuild switch --rollback; \
  else \
    sudo nixos-rebuild switch --rollback; \
  fi

bootstrap:
  @echo "Running host bootstrap checklist..."
  @just --justfile "$HOME/.config/just/justfile" doctor

post-switch:
  @echo "Post-switch checks..."
  @just --justfile "$HOME/.config/just/justfile" host-info
  @just --justfile "$HOME/.config/just/justfile" user-services || true
  @just --justfile "$HOME/.config/just/justfile" tailscale-status || true

ocr-shot:
  @$HOME/.local/bin/ocr-screenshot

ocr-image FILE:
  @$HOME/.local/bin/ocr-image {{FILE}}

cliphist:
  @$HOME/.local/bin/cliphist-wofi
