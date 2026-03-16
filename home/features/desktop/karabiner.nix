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
    };
    profiles = [
      {
        name = "Default";
        selected = true;
        # CapsLock → Ctrl at hardware level (no chaining risk)
        simple_modifications = [
          {
            from.key_code = "caps_lock";
            to = [{key_code = "left_control";}];
          }
        ];
        complex_modifications = {
          rules = [
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
