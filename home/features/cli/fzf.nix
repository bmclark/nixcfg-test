{
  config,
  lib,
  theme,
  ...
}:
with lib; let
  cfg = config.features.cli.fzf;
  palette = theme.palette;
in {
  options.features.cli.fzf.enable = mkEnableOption "enable fuzzy finder";

  config = mkIf cfg.enable {
    programs.fzf = {
      enable = true;
      enableFishIntegration = config.features.cli.fish.enable;
      enableZshIntegration = config.features.cli.zsh.enable;

      colors = {
        "fg" = palette.fg;
        "bg" = palette.bg;
        "hl" = palette.purple;
        "fg+" = palette.fg;
        "bg+" = palette.selection;
        "hl+" = palette.purple;
        "info" = palette.orange;
        "prompt" = palette.green;
        "pointer" = palette.pink;
        "marker" = palette.pink;
        "spinner" = palette.orange;
        "header" = palette.comment;
      };
      defaultOptions = [
        "--preview='bat --color=always -n {}'"
        "--bind 'ctrl-/:toggle-preview'"
      ];
      defaultCommand = "fd --type f --exclude .git --follow --hidden";
      changeDirWidgetCommand = "fd --type d --exclude .git --follow --hidden";
    };
  };
}
