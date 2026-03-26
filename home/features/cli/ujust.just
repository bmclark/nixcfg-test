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
  @bash -eu -c 'repo="${NIXCFG_REPO:-$HOME/nixcfg}"; host="$(hostname -s)"; os="$(uname -s)"; kernel="$(uname -r)"; uptime_info="$(uptime -p 2>/dev/null | sed "s/^up //")"; if [ -z "$uptime_info" ]; then uptime_info="$(uptime | sed -E "s/^.*up ([^,]+),.*$/\1/")"; fi; shell_name="$(basename "$SHELL")"; if command -v tailscale >/dev/null 2>&1; then tail_state="$(tailscale status --json 2>/dev/null | jq -r ".BackendState // empty" 2>/dev/null || true)"; tail_ip="$(tailscale ip -4 2>/dev/null | head -n1 || true)"; else tail_state="unavailable"; tail_ip=""; fi; if [ -L /run/current-system ]; then generation="$(basename "$(readlink /run/current-system)")"; elif command -v darwin-rebuild >/dev/null 2>&1 && [ -L /nix/var/nix/profiles/system ]; then generation="$(basename "$(readlink /nix/var/nix/profiles/system)")"; else generation="unknown"; fi; if [ -d "$repo/.git" ]; then if git -C "$repo" diff --quiet && git -C "$repo" diff --cached --quiet; then tree_state="clean"; tree_color="2"; else tree_state="dirty"; tree_color="3"; fi; flake_lock="$(date -r "$repo/flake.lock" "+%Y-%m-%d %H:%M" 2>/dev/null || stat -c "%y" "$repo/flake.lock" 2>/dev/null || echo unknown)"; else tree_state="unknown"; tree_color="7"; flake_lock="unknown"; fi; if [ -n "$tail_ip" ]; then tail_label="$tail_ip"; elif [ -n "$tail_state" ]; then tail_label="$tail_state"; else tail_label="disconnected"; fi; card="$(printf "Host: %s\nOS: %s\nKernel: %s\nUptime: %s\nShell: %s\nTailscale: %s\nGeneration: %s\nnixcfg tree: %s\nflake.lock: %s" "$host" "$os" "$kernel" "$uptime_info" "$shell_name" "$tail_label" "$generation" "$tree_state" "$flake_lock")"; gum style --border normal --margin "1 0" --padding "1 2" --border-foreground 12 --foreground 15 "$card"'

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
    repo="${NIXCFG_REPO:-$HOME/nixcfg}"; \
    if just --justfile "$repo/justfile" --working-directory "$repo" check >/tmp/ujust-check.$$ 2>&1; then ok "flake check passed"; \
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
  @repo="${NIXCFG_REPO:-$HOME/nixcfg}"; \
    just --justfile "$repo/justfile" --working-directory "$repo" check

nixcfg-update:
  @repo="${NIXCFG_REPO:-$HOME/nixcfg}"; \
    just --justfile "$repo/justfile" --working-directory "$repo" update

nixcfg-update-switch MESSAGE="chore: update flake inputs":
  @bash -eu -o pipefail -c '\
    repo="${NIXCFG_REPO:-$HOME/nixcfg}"; \
    if [ -n "$(git -C "$repo" status --porcelain)" ]; then \
      echo "nixcfg repo has uncommitted changes; aborting update-switch" >&2; \
      echo "commit, stash, or clean the repo first" >&2; \
      exit 1; \
    fi; \
    just --justfile "$repo/justfile" --working-directory "$repo" update; \
    if [ -z "$(git -C "$repo" diff --name-only -- flake.lock)" ] && [ -z "$(git -C "$repo" diff --cached --name-only -- flake.lock)" ]; then \
      echo "flake.lock unchanged; skipping commit"; \
    else \
      git -C "$repo" add flake.lock; \
      git -C "$repo" commit -m "{{MESSAGE}}"; \
    fi; \
    just --justfile "$repo/justfile" --working-directory "$repo" switch \
  '

update MESSAGE="chore: update flake inputs":
  @bash -eu -o pipefail -c '\
    section() { echo; gum style --bold --foreground 12 "$1"; }; \
    ok() { gum style --foreground 2 "OK  $1"; }; \
    warn() { gum style --foreground 3 "WARN $1"; }; \
    fail() { gum style --foreground 1 "FAIL $1"; }; \
    skip() { gum style --foreground 7 "SKIP $1"; }; \
    os="$(uname -s)"; \
    repo="${NIXCFG_REPO:-$HOME/nixcfg}"; \
    status_nix="ok"; status_brew="skipped"; status_flatpak="skipped"; status_firmware="skipped"; status_repos="skipped"; \
    \
    section "System (nix)"; \
    if git -C "$repo" diff --quiet 2>/dev/null && git -C "$repo" diff --cached --quiet 2>/dev/null; then \
      if git -C "$repo" pull --ff-only 2>/dev/null; then \
        ok "pulled latest nixcfg"; \
      else \
        warn "could not pull nixcfg (network or diverged history)"; \
        status_nix="warn"; \
      fi; \
    else \
      warn "nixcfg has uncommitted changes, skipping pull"; \
      status_nix="warn"; \
    fi; \
    if just --justfile "$repo/justfile" --working-directory "$repo" update; then \
      ok "flake inputs updated"; \
    else \
      fail "flake update failed"; \
      status_nix="fail"; \
    fi; \
    if ! git -C "$repo" diff --quiet -- flake.lock 2>/dev/null || ! git -C "$repo" diff --cached --quiet -- flake.lock 2>/dev/null; then \
      git -C "$repo" add flake.lock; \
      git -C "$repo" commit -m "{{MESSAGE}}" -- flake.lock; \
      ok "committed flake.lock"; \
    else \
      ok "flake.lock unchanged"; \
    fi; \
    if [ "$status_nix" = "fail" ]; then \
      warn "skipping switch due to failed flake update"; \
    elif just --justfile "$repo/justfile" --working-directory "$repo" switch; then \
      ok "system switched"; \
    else \
      fail "system switch failed"; \
      status_nix="fail"; \
    fi; \
    \
    section "Homebrew"; \
    if [ "$os" = "Darwin" ] && command -v brew >/dev/null 2>&1; then \
      if brew update && brew upgrade; then \
        ok "homebrew updated"; \
        status_brew="ok"; \
      else \
        fail "homebrew update failed"; \
        status_brew="fail"; \
      fi; \
    else \
      skip "not macOS or brew not found"; \
    fi; \
    \
    section "Flatpak"; \
    if [ "$os" = "Linux" ] && command -v flatpak >/dev/null 2>&1; then \
      if flatpak update -y; then \
        ok "flatpak updated"; \
        status_flatpak="ok"; \
      else \
        fail "flatpak update failed"; \
        status_flatpak="fail"; \
      fi; \
    else \
      skip "not Linux or flatpak not found"; \
    fi; \
    \
    section "Firmware"; \
    if [ "$os" = "Linux" ] && command -v fwupdmgr >/dev/null 2>&1; then \
      status_firmware="ok"; \
      if fwupdmgr refresh 2>/dev/null; then \
        ok "firmware metadata refreshed"; \
      else \
        warn "could not refresh firmware metadata"; \
        status_firmware="warn"; \
      fi; \
      fwupdmgr get-updates 2>/dev/null || true; \
    else \
      skip "not Linux or fwupdmgr not found"; \
    fi; \
    \
    section "Git repos (~/src)"; \
    if [ -d "$HOME/src" ]; then \
      shopt -s nullglob; \
      repos=("$HOME/src"/*/); \
      shopt -u nullglob; \
      if [ ${#repos[@]} -eq 0 ]; then \
        skip "no directories in ~/src"; \
      else \
        status_repos="ok"; \
        for dir in "${repos[@]}"; do \
          name="$(basename "$dir")"; \
          if [ -d "$dir/.git" ]; then \
            if git -C "$dir" fetch --all 2>/dev/null; then \
              ok "fetched $name"; \
            else \
              warn "failed to fetch $name"; \
              status_repos="warn"; \
            fi; \
          fi; \
        done; \
      fi; \
    else \
      skip "~/src not found"; \
    fi; \
    \
    section "Summary"; \
    summary="$(printf "%-12s %s\n%-12s %s\n%-12s %s\n%-12s %s\n%-12s %s" \
      "Nix:" "$status_nix" \
      "Homebrew:" "$status_brew" \
      "Flatpak:" "$status_flatpak" \
      "Firmware:" "$status_firmware" \
      "Git repos:" "$status_repos")"; \
    gum style --border normal --margin "1 0" --padding "1 2" --border-foreground 12 "$summary"; \
    \
    if [ "$status_nix" = "fail" ] || [ "$status_brew" = "fail" ] || [ "$status_flatpak" = "fail" ] || [ "$status_firmware" = "fail" ] || [ "$status_repos" = "fail" ]; then \
      exit 1; \
    fi \
  '

nixcfg-switch:
  @repo="${NIXCFG_REPO:-$HOME/nixcfg}"; \
    just --justfile "$repo/justfile" --working-directory "$repo" switch

nixcfg-home-switch:
  @repo="${NIXCFG_REPO:-$HOME/nixcfg}"; \
    just --justfile "$repo/justfile" --working-directory "$repo" home-switch

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

gc:
  @bash -eu -c '\
    echo "Deleting old system generations..."; \
    sudo nix-collect-garbage -d; \
    echo; echo "Deleting old home-manager generations..."; \
    nix-collect-garbage -d; \
    echo; echo "Updating boot entries..."; \
    if [ -L /run/current-system ]; then \
      sudo /run/current-system/bin/switch-to-configuration boot; \
    fi; \
    echo; echo "Done. Disk usage:"; \
    df -h / \
  '

wallpaper-mode MODE="":
  @bash -eu -c '\
    if [ -z "{{MODE}}" ]; then \
      current="sfw"; \
      [ -f "$HOME/.local/state/wallpaper-mode" ] && current="$(cat "$HOME/.local/state/wallpaper-mode")"; \
      echo "Current mode: $current"; \
      echo "Usage: ujust wallpaper-mode [sfw|nsfw]"; \
    else \
      "$HOME/.local/bin/wallpaper-mode" "{{MODE}}"; \
    fi \
  '

wallpaper:
  @$HOME/.local/bin/wallpaper-random

ocr-shot:
  @$HOME/.local/bin/ocr-screenshot

ocr-image FILE:
  @$HOME/.local/bin/ocr-image {{FILE}}

cliphist:
  @$HOME/.local/bin/cliphist-wofi
