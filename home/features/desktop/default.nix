# Desktop modules: window manager, browsers, fonts, input remapping, and remote access helpers.
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.desktop.remoteDesktop;
  macminiRemote = pkgs.writeShellApplication {
    name = "macmini-remote";
    runtimeInputs = [pkgs.remmina];
    text = ''
      default_target=${escapeShellArg cfg.defaultHost}
      target="''${1:-$default_target}"
      exec remmina -c "vnc://$target"
    '';
  };
in {
  imports = [
    ./fonts.nix
    ./hyprland.nix
    ./wayland.nix
    ./firefox.nix
    ./chromium.nix
    ./karabiner.nix
  ];

  options.features.desktop.remoteDesktop = {
    enable = mkEnableOption "remote desktop client tools";

    defaultHost = mkOption {
      type = types.str;
      default = "macmini";
      example = "100.101.102.103";
      description = ''
        Default host or Tailscale IP for the `macmini-remote` helper.
        The default assumes Tailscale MagicDNS resolves `macmini`.
      '';
    };
  };

  config = mkMerge [
    {
      home.packages = with pkgs; [tree];
    }
    (mkIf (cfg.enable && pkgs.stdenv.isLinux) {
      home.packages = [
        pkgs.remmina
        macminiRemote
      ];
    })
  ];
}
