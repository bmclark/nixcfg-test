{
  pkgs,
  lib,
  inputs,
  outputs,
  config,
  ...
}:
with lib; let
  flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
  screenSharingCfg = config.remoteAccess.screenSharing;
  kickstart = "/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart";
  allowedScreenSharingUsers =
    if screenSharingCfg.allowedUsers == []
    then [config.system.primaryUser]
    else screenSharingCfg.allowedUsers;
  allowedScreenSharingUsersCsv = concatStringsSep "," allowedScreenSharingUsers;
in {
  imports = [
    ./users
    ./karabiner.nix
  ];

  options.remoteAccess.screenSharing = {
    enable = mkEnableOption "macOS Screen Sharing over the built-in VNC service";

    allowedUsers = mkOption {
      type = types.listOf types.str;
      default = [];
      example = ["bclark"];
      description = ''
        Local macOS accounts allowed to authenticate to Screen Sharing.
        When left empty, the system primary user is allowed.
      '';
    };
  };

  config = mkMerge [
    {
      nixpkgs = {
        config.allowUnfree = true;
      };

      nix = {
        settings = {
          experimental-features = "nix-command flakes";
          trusted-users = [
            "root"
            "bclark"
          ];
        };
        gc = {
          automatic = true;
          options = "--delete-older-than 30d";
        };
        optimise.automatic = true;
        registry = lib.mapAttrs (_: flake: {inherit flake;}) flakeInputs;
        nixPath =
          ["/etc/nix/path"]
          ++ lib.mapAttrsToList (flakeName: _: "${flakeName}=flake:${flakeName}") flakeInputs;
      };

      programs.zsh.enable = true;
    }
    (mkIf screenSharingCfg.enable {
      assertions = [
        {
          assertion = allowedScreenSharingUsers != [];
          message = "remoteAccess.screenSharing.allowedUsers must contain at least one user.";
        }
      ];

      system.activationScripts.postActivation.text = mkAfter ''
        echo "configuring macOS Screen Sharing for ${allowedScreenSharingUsersCsv}" >&2
        ${kickstart} -activate
        ${kickstart} -configure -access -on -users ${escapeShellArg allowedScreenSharingUsersCsv} -privs -all
        ${kickstart} -configure -allowAccessFor -specifiedUsers
        ${kickstart} -restart -agent -console
      '';
    })
  ];
}
