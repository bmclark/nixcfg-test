# Ghostty terminal emulator with switchable theme, JetBrainsMono Nerd Font, and clipboard config.
# No auto-logging support (GitHub #5209) -- use tmux-logging plugin instead.
# Linux: installed from nixpkgs. macOS: installed via Homebrew cask (darwin/common/homebrew.nix).
# Dropdown terminal is configured in hyprland.nix via special workspace (Linux only).
{
  lib,
  config,
  pkgs,
  theme,
  ...
}: let
  cfg = config.features.cli.ghostty;
  configText = ''
    # Theme
    theme = ${theme.ghosttyThemeName}

    # Font: JetBrainsMono Nerd Font with ligatures
    font-family = JetBrainsMono Nerd Font
    font-size = 12

    # Window
    window-padding-x = 10
    window-padding-y = 10
    window-theme = dark

    # Cursor
    cursor-style = block
    cursor-style-blink = false

    # Scrollback: 100k lines for long build output
    scrollback-limit = 100000

    # Clipboard: allow read/write for tmux-yank and other tools
    clipboard-read = allow
    clipboard-write = allow
    copy-on-select = clipboard

    # Shell integration: marks command boundaries for prompt navigation
    # Use Ctrl+Shift+Up/Down to jump between prompts
    shell-integration = zsh
    confirm-close-surface = false

    # Keybinds: clipboard
    keybind = ctrl+shift+c=copy_to_clipboard
    keybind = ctrl+shift+v=paste_from_clipboard

    # Keybinds: font size
    keybind = ctrl+equal=increase_font_size:1
    keybind = ctrl+minus=decrease_font_size:1
    keybind = ctrl+0=reset_font_size

    # Keybinds: tab management
    keybind = ctrl+shift+t=new_tab
    keybind = ctrl+shift+w=close_surface
    keybind = ctrl+tab=next_tab
    keybind = ctrl+shift+tab=previous_tab
  '';
in {
  options.features.cli.ghostty.enable =
    lib.mkEnableOption "enable Ghostty terminal emulator";

  config = lib.mkIf cfg.enable (lib.mkMerge [
    # Linux: install from nixpkgs + write XDG config
    (lib.mkIf pkgs.stdenv.isLinux {
      home.sessionVariables.TERMINAL = "ghostty";
      home.packages = [pkgs.ghostty];
      xdg.configFile."ghostty/config".text = configText;
    })
    # macOS: config-only (Ghostty.app installed via darwin/common/homebrew.nix cask)
    (lib.mkIf pkgs.stdenv.isDarwin {
      home.sessionVariables.TERMINAL = "ghostty";
      home.file.".config/ghostty/config".text = configText;
    })
  ]);
}
