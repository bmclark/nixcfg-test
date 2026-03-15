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
        complex_modifications = {
          rules = [
            {
              description = "Remap left command to left control";
              manipulators = [
                {
                  type = "basic";
                  from = {
                    key_code = "left_command";
                    modifiers.optional = ["any"];
                  };
                  to = [
                    {key_code = "left_control";}
                  ];
                }
              ];
            }
            {
              description = "Remap right command to right control";
              manipulators = [
                {
                  type = "basic";
                  from = {
                    key_code = "right_command";
                    modifiers.optional = ["any"];
                  };
                  to = [
                    {key_code = "right_control";}
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
      # Keep application shortcuts on Ctrl while WM shortcuts live on Super.
      xdg.configFile."karabiner/karabiner.json".text =
        builtins.toJSON karabinerConfig;
    });
}
