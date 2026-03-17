# Shared workspace layout and app assignments for cross-platform window management.
# Consumed by aerospace.nix (macOS) and hyprland.nix (Linux).
{
  workspaces = {
    "1" = { name = "admin";    darwin = ["Mail" "Notes" "Calendar" "Bitwarden"];                    linux = ["thunderbird" "notes" "calendar" "bitwarden" "Bitwarden"]; };
    "2" = { name = "browser";  darwin = ["Safari" "Google Chrome"];                                 linux = ["firefox" "chromium"]; };
    "3" = { name = "ai";       darwin = ["Claude" "ChatGPT" "Codex"];                               linux = ["Claude" "ChatGPT"]; };
    "4" = { name = "editor";   darwin = ["Emacs" "Code" "Xcode"];                                   linux = ["Emacs" "Code"]; };
    "5" = { name = "terminal"; darwin = ["Ghostty"];                                                 linux = ["Ghostty"]; };
    "6" = { name = "media";    darwin = ["Spotify" "Audacity" "GarageBand" "iMovie"];               linux = ["Spotify" "Audacity"]; };
  };
  # Workspaces 7-10: no app assignments (flexible use)
}
