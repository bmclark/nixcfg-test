# Comprehensive `ujust update` Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rewrite `ujust update` to be a one-stop system update command (like Universal Blue) that updates nix, homebrew, flatpak, firmware, and git repos with a pass/fail summary.

**Architecture:** Single inline bash recipe in `ujust.just`, matching the existing `doctor` pattern. Platform-gated sections run sequentially with status tracking via bash variables. Summary table at the end.

**Tech Stack:** just (justfile), bash, gum (TUI formatting)

---

### Task 1: Rewrite the `update` recipe

**Files:**
- Modify: `home/features/cli/ujust.just:129-130`

- [ ] **Step 1: Replace the `update` recipe with the comprehensive version**

Replace lines 129-130 in `home/features/cli/ujust.just` (the current `update` recipe) with the following:

```just
update MESSAGE="chore: update flake inputs":
  @bash -eu -c '\
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
    if just --justfile "$repo/justfile" --working-directory "$repo" switch; then \
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
```

Key design decisions:
- The recipe inlines its nix logic rather than delegating to `nixcfg-update-switch` (different dirty-repo semantics — warn and continue instead of abort)
- `git commit -- flake.lock` ensures only flake.lock is committed even if other files are staged
- `shopt -s nullglob` prevents the glob from expanding to a literal string when `~/src` is empty
- `fwupdmgr get-updates` exit code is ignored (non-zero when no updates available)
- Exit 1 only if any section FAILed; warnings and skips are exit 0

- [ ] **Step 2: Verify the justfile parses correctly**

Run: `just --justfile home/features/cli/ujust.just --list`

Expected: The `update` recipe appears in the list with its parameter `MESSAGE`.

- [ ] **Step 3: Commit**

```bash
git add home/features/cli/ujust.just
git commit -m "feat: comprehensive ujust update with brew, flatpak, firmware, git repos"
```
