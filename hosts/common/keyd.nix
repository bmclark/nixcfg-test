# keyd: system-level key remapping daemon.
# Remaps CapsLock→Ctrl (emacs) and physical Ctrl→Hyper (WM).
# Runs at evdev level, transparent to Hyprland and all apps.
{...}: {
  services.keyd = {
    enable = true;
    keyboards.default = {
      ids = ["*"];
      settings = {
        main = {
          capslock = "leftcontrol";
          leftcontrol = "hyper";
          rightcontrol = "hyper";
        };
      };
    };
  };
}
