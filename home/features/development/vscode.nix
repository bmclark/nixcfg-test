{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.features.development.vscode;
  nixpkgs.config.allowUnfreePredicate = _: true;
  nixpkgs.config.allowUnfree = true;
in {
  options.features.development.vscode.enable = mkEnableOption "enable vscode";

  config = mkIf cfg.enable {
    programs.vscode = {
      enable = true;
    };
  };
}
