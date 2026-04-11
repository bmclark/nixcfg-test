# cmux terminal — macOS-only wrapper around Ghostty renderer with workspace management.
# Reads Ghostty config from ~/.config/ghostty/config (shared with ghostty.nix).
# App-specific settings live in ~/.config/cmux/settings.json.
# Installed via Homebrew cask (darwin/common/homebrew.nix).
{
  lib,
  config,
  pkgs,
  theme,
  ...
}: let
  cfg = config.features.cli.cmux;
  palette = theme.palette;
  settings = builtins.toJSON {
    "$schema" = "https://raw.githubusercontent.com/manaflow-ai/cmux/main/web/data/cmux-settings.schema.json";
    schemaVersion = 1;
    app = {
      appearance = "dark";
      newWorkspacePlacement = "afterCurrent";
      minimalMode = true;
      warnBeforeQuit = true;
      sendAnonymousTelemetry = false;
    };
    notifications = {
      dockBadge = true;
      showInMenuBar = true;
      sound = "none";
    };
    sidebar = {
      branchLayout = "inline";
      showNotificationMessage = true;
      showBranchDirectory = true;
      showPullRequests = true;
      showSSH = true;
      showPorts = true;
      showLog = true;
      showProgress = true;
      showCustomMetadata = true;
    };
    workspaceColors = {
      indicatorStyle = "leftRail";
      colors = {
        Purple = palette.purple;
        Cyan = palette.cyan;
        Green = palette.green;
        Pink = palette.pink;
        Yellow = palette.yellow;
        Red = palette.red;
        Orange = palette.orange;
      };
    };
    sidebarAppearance = {
      tintColor = palette.bg;
      tintOpacity = 0.05;
    };
    automation = {
      claudeCodeIntegration = true;
      socketControlMode = "cmuxOnly";
    };
    browser = {
      defaultSearchEngine = "duckduckgo";
      showSearchSuggestions = true;
      theme = "dark";
      openTerminalLinksInCmuxBrowser = true;
    };
    shortcuts = {
      showModifierHoldHints = true;
    };
  };
in {
  options.features.cli.cmux.enable =
    lib.mkEnableOption "enable cmux terminal (macOS only)";

  config = lib.mkIf cfg.enable (lib.mkIf pkgs.stdenv.isDarwin {
    home.file.".config/cmux/settings.json".text = settings;
  });
}
