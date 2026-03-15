# Tokyo Night color palette.
# Same attribute structure as dracula.nix for switchable theme support.
{
  vscodeThemeName = "Tokyo Night";
  ghosttyThemeName = "TokyoNight";
  batThemeName = "TwoDark";
  deltaThemeName = "TwoDark";
  btopThemeName = "tokyo-night";
  starshipPaletteName = "tokyo-night";
  emacsThemePackage = "doom-themes";
  emacsThemeName = "doom-tokyo-night";
  emacsThemeInit = "(require 'doom-themes)";
  gtkThemeName = "Tokyonight-Dark";
  mcSkin = null; # no official Tokyo Night MC skin; uses built-in dark skin
  palette = {
    bg = "#1a1b26";
    fg = "#c0caf5";
    comment = "#565f89";
    cyan = "#7dcfff";
    green = "#9ece6a";
    orange = "#ff9e64";
    pink = "#bb9af7";
    purple = "#9d7cd8";
    red = "#f7768e";
    yellow = "#e0af68";
    selection = "#283457";
  };
}
