# Hyprland window manager with full rice: switchable theme, blur, window rules,
# gestures, and workspace assignments. Aligned with ADR-003 (keyboard strategy)
# and ADR-004 (theme standardization).
{
  config,
  lib,
  pkgs,
  theme,
  ...
}:
with lib; let
  cfg = config.features.desktop.hyprland;
  palette = theme.palette;
  stripHash = color: builtins.replaceStrings ["#"] [""] color;
  # Simple rgba helper keeps Dracula palette usage consistent throughout the config.
  rgba = color: alpha: "rgba(${stripHash color}${alpha})";
in {
  options.features.desktop.hyprland.enable = mkEnableOption "hyprland config";

  config = mkIf cfg.enable {
    home.sessionVariables = {
      XDG_CURRENT_DESKTOP = "Hyprland";
      XDG_SESSION_DESKTOP = "Hyprland";
      XDG_SESSION_TYPE = "wayland";
      SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/keyring/ssh";
    };

    wayland.windowManager.hyprland = {
      enable = true;
      # hyprexpo plugin disabled: incompatible with current Hyprland (missing HookSystemManager.hpp)
      # plugins = [pkgs.hyprlandPlugins.hyprexpo];
      systemd = {
        enable = true;
        variables = ["--all"];
      };

      settings = {
        # --- XWayland ---------------------------------------------------------
        xwayland.force_zero_scaling = true;

        # --- Runtime Environment ---------------------------------------------
        exec-once = [
          "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE"
          "dbus-update-activation-environment --systemd --all"
          # Wallpaper daemon (swww) with initial random wallpaper
          "swww-daemon && sleep 0.5 && $HOME/.local/bin/wallpaper-random"
          "waybar"
          "blueman-applet"
          # Dropdown terminal: starts hidden in special workspace, toggled with Super+`
          "[workspace special:terminal silent] $TERMINAL"
        ];

        env = [
          "XCURSOR_SIZE,32"
          "WLR_NO_HARDWARE_CURSORS,1"
          "XDG_CURRENT_DESKTOP,Hyprland"
          "XDG_SESSION_DESKTOP,Hyprland"
          "XDG_SESSION_TYPE,wayland"
          "GTK_THEME,${theme.gtkThemeName}"
        ];

        # --- Input -----------------------------------------------------------
        input = {
          kb_layout = "us";
          kb_variant = "";
          kb_model = "";
          kb_rules = "";
          kb_options = "ctrl:nocaps"; # CapsLock → Ctrl
          follow_mouse = 1;
          sensitivity = 0;
          touchpad.natural_scroll = false;
        };

        # --- Core Layout -----------------------------------------------------
        general = {
          gaps_in = 5;
          gaps_out = 10; # Slightly more outer gap for breathing room
          border_size = 1;
          layout = "dwindle";
          # Dracula palette for border gradients (#ff79c6 pink → #bd93f9 purple)
          "col.active_border" =
            "${rgba palette.pink "ee"} ${rgba palette.purple "ee"} 45deg";
          "col.inactive_border" = rgba palette.comment "aa";
        };

        # --- Decorations -----------------------------------------------------
        decoration = {
          rounding = 12;
          active_opacity = 0.95; # 0.95 is more readable than 0.9
          inactive_opacity = 0.5;
          blur = {
            enabled = true;
            size = 6;
            passes = 3;
            vibrancy = 0.20;
            contrast = 1.0;
            brightness = 0.9;
            noise = 0.01;
            xray = true; # Blurred layers (waybar) show through for glass effect
            popups = true;
            popups_ignorealpha = 0.25;
          };
          shadow = {
            enabled = true;
            range = 18;
            render_power = 3;
            ignore_window = true;
            offset = "0 6";
            scale = 1.0;
            color = rgba palette.bg "66";
          };
        };

        # --- Animations ------------------------------------------------------
        animations = {
          enabled = true;
          bezier = [
            "easeOutQuint, 0.23, 1, 0.32, 1"
            "easeInOutCubic, 0.65, 0.05, 0.36, 1"
            "quick, 0.15, 0, 0.1, 1"
          ];
          animation = [
            "windowsIn, 1, 6, easeOutQuint, popin 85%"
            "windowsOut, 1, 5, easeInOutCubic, popin 80%"
            "windowsMove, 1, 6, easeInOutCubic"
            "border, 1, 8, easeInOutCubic"
            "borderangle, 1, 8, easeInOutCubic"
            "fadeIn, 1, 6, easeOutQuint"
            "fadeOut, 1, 6, quick"
            "layers, 1, 6, easeOutQuint"
            "workspaces, 1, 7, easeOutQuint, slidefade 40%"
          ];
        };

        # --- Window Management -----------------------------------------------
        dwindle = {
          pseudotile = true;
          preserve_split = true;
        };

        # Touchpad gesture: 3-finger swipe to change workspace (new syntax for 0.51+)
        gesture = [
          "3, horizontal, workspace"
        ];

        # --- Layer Rules: frosted glass on overlays (0.53+ syntax) -----------
        layerrule = [
          "blur on, ignore_alpha 0.1, match:namespace gtk-layer-shell"
          "blur on, ignore_alpha 0.1, match:namespace waybar"
          "blur on, ignore_alpha 0.1, match:namespace wofi"
        ];

        # --- Window Rules (0.48+ syntax) --------------------------------------
        windowrule = [
          # Float dialog-like windows automatically
          "float on, match:class ^(?i:file_progress|confirm|dialog|download|notification|error|splash|confirmreset)$"
          "float on, match:title ^(Open File|Save File|branchdialog)$"

          # Application-specific float rules
          "float on, match:class ^(Wofi|dunst|Viewnior|feh|blueman-manager)$"
          "float on, match:class ^(pavucontrol(-qt)?|org.gnome.FileRoller)$"
          "animation none, match:class ^(Wofi)$"

          # Volume control sizing and positioning
          "float on, match:title ^(Volume Control)$"
          "size 800 600, match:title ^(Volume Control)$"
          "move 75 44%, match:title ^(Volume Control)$"

          # Picture-in-Picture: float, pin, and resize
          "float on, pin on, size 480 270, match:title ^(Picture-in-Picture)$"

          # Media / full-screen rules (idleinhibit removed in 0.53+, use hypridle)
          "fullscreen on, float on, match:title ^(wlogout)$"

          # Workspace assignments
          "workspace 1, match:class ^(Emacs)$"
          "workspace 2, match:class ^(firefox)$"
          "workspace 3, match:class ^(code-url-handler)$" # VS Code

          # Force full opacity on browsers (blur looks bad through text)
          "opacity 1.0 override 1.0, match:class ^(firefox|chromium-browser)$"

          # Dropdown terminal: float and size for special workspace
          "float on, size 100% 50%, move 0 0, animation slide, match:workspace name:special:terminal"
        ];

        # --- Keybindings -----------------------------------------------------
        "$mainMod" = "SUPER";
        # Ctrl-focused bindings follow CUA conventions, Super controls the WM, and Emacs-style navigation
        # handles directional focus per ADR-003.
        bind = [
          # Core launcher bindings
          "$mainMod, Return, exec, $TERMINAL"
          "$mainMod, D, exec, wofi --show drun"
          "$mainMod, Space, togglefloating"
          "$mainMod, F, fullscreen"
          "$mainMod, E, exec, thunar"
          "$mainMod, L, exec, hyprlock"
          "$mainMod, Escape, exec, wlogout -p layer-shell"
          "$mainMod, comma, workspace, r-1"
          "$mainMod, period, workspace, r+1"

          # Dropdown terminal (Super+` toggles special:terminal workspace)
          "$mainMod, grave, togglespecialworkspace, terminal"

          # Wallpaper controls
          "$mainMod SHIFT, W, exec, $HOME/.local/bin/wallpaper-random"

          # CUA / application bindings
          "ALT, F4, killactive"
          "ALT, Tab, cyclenext"
          "ALT SHIFT, Tab, cyclenext, prev"

          # Emacs-style focus navigation
          "CTRL ALT, B, movefocus, l"
          "CTRL ALT, F, movefocus, r"
          "CTRL ALT, P, movefocus, u"
          "CTRL ALT, N, movefocus, d"

          # Emacs-style window movement
          "CTRL ALT SHIFT, B, movewindow, l"
          "CTRL ALT SHIFT, F, movewindow, r"
          "CTRL ALT SHIFT, P, movewindow, u"
          "CTRL ALT SHIFT, N, movewindow, d"

          # Workspace management
          "$mainMod, 1, workspace, 1"
          "$mainMod, 2, workspace, 2"
          "$mainMod, 3, workspace, 3"
          "$mainMod, 4, workspace, 4"
          "$mainMod, 5, workspace, 5"
          "$mainMod, 6, workspace, 6"
          "$mainMod, 7, workspace, 7"
          "$mainMod, 8, workspace, 8"
          "$mainMod, 9, workspace, 9"
          "$mainMod, 0, workspace, 10"
          "$mainMod SHIFT, 1, movetoworkspace, 1"
          "$mainMod SHIFT, 2, movetoworkspace, 2"
          "$mainMod SHIFT, 3, movetoworkspace, 3"
          "$mainMod SHIFT, 4, movetoworkspace, 4"
          "$mainMod SHIFT, 5, movetoworkspace, 5"
          "$mainMod SHIFT, 6, movetoworkspace, 6"
          "$mainMod SHIFT, 7, movetoworkspace, 7"
          "$mainMod SHIFT, 8, movetoworkspace, 8"
          "$mainMod SHIFT, 9, movetoworkspace, 9"
          "$mainMod SHIFT, 0, movetoworkspace, 10"

          # Screenshots
          "$mainMod SHIFT, S, exec, bash -lc 'grim -g \"$(slurp)\" \"$HOME/Pictures/Screenshots/$(date +%Y-%m-%d-%H%M%S).png\"'"
          "$mainMod SHIFT, Print, exec, bash -lc 'grim \"$HOME/Pictures/Screenshots/$(date +%Y-%m-%d-%H%M%S).png\"'"

          # Workspace cycling with mouse wheel
          "$mainMod, mouse_down, workspace, r-1"
          "$mainMod, mouse_up, workspace, r+1"
        ];

        bindm = [
          "$mainMod, mouse:272, movewindow"
          "$mainMod, mouse:273, resizewindow"
        ];
      };
    };
  };
}
