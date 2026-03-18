# keyd: system-level key remapping daemon.
# Remaps CapsLock→Ctrl (emacs), physical Ctrl→Super (WM),
# and physical Super→Ctrl for common CUA shortcuts (copy/paste/undo).
# Runs at evdev level, transparent to Hyprland and all apps.
#
# Note: keyd cannot exclude per-app (it operates below the compositor).
# keyd-application-mapper supports X11/sway/GNOME but not Hyprland.
# For Emacs on Linux, CUA mode handles the translated Ctrl keys contextually.
{...}: {
  services.keyd = {
    enable = true;
    keyboards.default = {
      ids = ["*"];
      settings = {
        main = {
          capslock = "leftcontrol";
          leftcontrol = "leftmeta";
          rightcontrol = "rightmeta";
          leftmeta = "layer(super_cua)";
          rightmeta = "layer(super_cua)";
        };
        # Super (Cmd) → Ctrl for common CUA shortcuts.
        # Makes Cmd+C/V/X/Z/S/A/F/W/T/N/Q match macOS muscle memory.
        "super_cua" = {
          c = "C-c";       # copy
          v = "C-v";       # paste
          x = "C-x";       # cut
          z = "C-z";       # undo
          # redo: shift+z not valid in keyd 2.6.0 layer syntax
          a = "C-a";       # select all
          s = "C-s";       # save
          f = "C-f";       # find
          w = "C-w";       # close tab/window
          t = "C-t";       # new tab
          n = "C-n";       # new window
          q = "C-q";       # quit
          l = "C-l";       # address bar / go-to-line
          r = "C-r";       # reload / replace
          p = "C-p";       # print / quick-open
        };
      };
    };
  };
}
