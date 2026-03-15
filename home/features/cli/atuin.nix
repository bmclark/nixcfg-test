# Atuin shell history with fuzzy search, local-only storage (no sync).
{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.features.cli.atuin;
in {
  options.features.cli.atuin.enable = mkEnableOption "Atuin shell history";

  config = mkIf cfg.enable {
    programs.atuin = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        auto_sync = false; # Local-only -- no cloud sync
        search_mode = "fuzzy";
        style = "compact";
        show_preview = true;
        enter_accept = true;
        filter_mode_shell_up_key_binding = "session";
      };
    };
  };
}
