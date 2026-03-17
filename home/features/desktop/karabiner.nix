{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.desktop.karabiner;
  karabinerConfig = {
    global = {
      ask_for_confirmation_before_quit = true;
      show_in_menu_bar = true;
      show_profile_name_in_menu_bar = false;
    };
    profiles = [
      {
        name = "Default";
        selected = true;
        # CapsLock is handled in complex_modifications (not simple_modifications)
        # to avoid the processing chain: simple runs before complex, so
        # simple CapsLock→Ctrl would feed into complex Ctrl→Hyper, breaking
        # CapsLock's role as plain Ctrl for Emacs/CUA bindings.
        parameters = {
          "delay_milliseconds_before_open_device" = 1000;
        };
        virtual_hid_keyboard = {
          keyboard_type_v2 = "ansi";
        };
        simple_modifications = [];
        complex_modifications = {
          rules = [
            {
              # Rule 1: CapsLock → Ctrl (for Emacs/CUA text editing)
              # Must be BEFORE the Ctrl→Hyper rules so CapsLock is consumed here
              # and never reaches the Hyper mapping.
              description = "CapsLock → Ctrl (text editing, Emacs)";
              manipulators = [
                {
                  type = "basic";
                  from = {
                    key_code = "caps_lock";
                    modifiers.optional = ["any"];
                  };
                  to = [
                    {
                      key_code = "left_control";
                    }
                  ];
                }
              ];
            }
            {
              description = "Physical Left Ctrl → Hyper (Ctrl+Alt+Cmd, no Shift)";
              manipulators = [
                {
                  type = "basic";
                  from = {
                    key_code = "left_control";
                    modifiers.optional = ["any"];
                  };
                  to = [
                    {
                      key_code = "left_control";
                      modifiers = ["left_option" "left_command"];
                    }
                  ];
                }
              ];
            }
            {
              description = "Physical Right Ctrl → Hyper (Ctrl+Alt+Cmd, no Shift)";
              manipulators = [
                {
                  type = "basic";
                  from = {
                    key_code = "right_control";
                    modifiers.optional = ["any"];
                  };
                  to = [
                    {
                      key_code = "right_control";
                      modifiers = ["right_option" "right_command"];
                    }
                  ];
                }
              ];
            }
          ];
        };
      }
    ];
  };
in {
  options.features.desktop.karabiner.enable =
    mkEnableOption "enable Karabiner-Elements configuration";

  config =
    mkIf cfg.enable
    (mkIf pkgs.stdenv.isDarwin {
      # CapsLock → Ctrl (emacs), physical Ctrl → Hyper (WM via Aerospace).
      xdg.configFile."karabiner/karabiner.json".text =
        builtins.toJSON karabinerConfig;
    });
}
