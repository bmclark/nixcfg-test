# SynthWave '84 color palette.
# Same attribute structure as dracula.nix for switchable theme support.
{
  vscodeThemeName = "SynthWave '84";
  ghosttyThemeName = "Synthwave";
  batThemeName = "Monokai Extended";
  deltaThemeName = "Monokai Extended";
  btopThemeName = "dracula"; # no synthwave btop theme; dracula is closest
  starshipPaletteName = "synthwave84";
  emacsThemePackage = "doom-themes";
  emacsThemeName = "doom-outrun-electric";
  emacsThemeInit = "(require 'doom-themes)";
  gtkThemeName = "Adwaita-dark";
  mcSkin = null; # no official SynthWave MC skin; uses built-in dark skin
  palette = {
    bg = "#262335";
    fg = "#ffffff";
    comment = "#848bbd";
    cyan = "#72f1b8";
    green = "#72f1b8";
    orange = "#fede5d";
    pink = "#ff7edb";
    purple = "#b084eb";
    red = "#fe4450";
    yellow = "#fede5d";
    selection = "#34294f";
  };
}
