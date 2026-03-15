# Desktop fonts: coding fonts, nerd fonts for icons, and system fonts.
# Monospace fallback chain: FiraCode → Hack → JetBrainsMono for consistent rendering.
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.desktop.fonts;
in {
  options.features.desktop.fonts.enable =
    mkEnableOption "install additional fonts for desktop apps";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      # Primary coding fonts
      fira-code
      fira-code-symbols
      hack-font

      # Nerd Font variants (icons for Starship, waybar, wofi, dunst)
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
      nerd-fonts.symbols-only # Pure icon fallback

      # System and UI fonts
      font-manager
      font-awesome_5
      noto-fonts
      meslo-lgs-nf # P10k compatibility if ever needed
    ];

    # Fontconfig monospace fallback chain
    fonts.fontconfig.defaultFonts.monospace = [
      "FiraCode Nerd Font"
      "Hack"
      "JetBrainsMono Nerd Font"
    ];
  };
}
