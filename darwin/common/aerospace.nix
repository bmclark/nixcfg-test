# Aerospace tiling window manager — nix-darwin service + full config.
# Keybindings mirror Hyprland (Linux) using Hyper (Ctrl+Alt+Cmd via Karabiner).
{pkgs, lib, ...}:
with lib; let
  kb = import ../../home/features/desktop/keybindings.nix;
  workspaceNames = map toString (range 1 10);
  aerospaceBin = "${pkgs.aerospace}/bin/aerospace";

  workspaceCycleNext = pkgs.writeShellApplication {
    name = "aerospace-workspace-next";
    text = ''
      cat <<'EOF' | ${aerospaceBin} workspace --wrap-around --stdin next
      ${concatStringsSep "\n" workspaceNames}
      EOF
    '';
  };
  workspaceCyclePrev = pkgs.writeShellApplication {
    name = "aerospace-workspace-prev";
    text = ''
      cat <<'EOF' | ${aerospaceBin} workspace --wrap-around --stdin prev
      ${concatStringsSep "\n" workspaceNames}
      EOF
    '';
  };
  moveToWorkspaceNext = pkgs.writeShellApplication {
    name = "aerospace-move-to-workspace-next";
    text = ''
      cat <<'EOF' | ${aerospaceBin} move-node-to-workspace --wrap-around --stdin next
      ${concatStringsSep "\n" workspaceNames}
      EOF
    '';
  };
  moveToWorkspacePrev = pkgs.writeShellApplication {
    name = "aerospace-move-to-workspace-prev";
    text = ''
      cat <<'EOF' | ${aerospaceBin} move-node-to-workspace --wrap-around --stdin prev
      ${concatStringsSep "\n" workspaceNames}
      EOF
    '';
  };
  lockScreen = pkgs.writeShellApplication {
    name = "aerospace-lock-screen";
    text = ''
      exec "/System/Library/CoreServices/Menu Extras/User.menu/Contents/Resources/CGSession" -suspend
    '';
  };
  scratchTerminal = pkgs.writeShellApplication {
    name = "aerospace-scratch-terminal";
    runtimeInputs = [pkgs.jq];
    text = ''
      current_workspace="$(${aerospaceBin} list-workspaces --focused --format '%{workspace}' 2>/dev/null || true)"

      if [ "$current_workspace" = "S" ]; then
        exec ${aerospaceBin} workspace-back-and-forth
      fi

      if ${aerospaceBin} list-windows --workspace S --format '%{app-name}' 2>/dev/null | grep -Fxq cmux; then
        exec ${aerospaceBin} workspace --auto-back-and-forth S
      fi

      before_ids="$(${aerospaceBin} list-windows --all --json 2>/dev/null | jq '[.[] | select(."app-name" == "cmux") | ."window-id"]')"

      ${aerospaceBin} workspace S
      open -na cmux

      for _ in $(seq 1 50); do
        new_id="$(${aerospaceBin} list-windows --all --json 2>/dev/null | jq -r --argjson before "$before_ids" '[.[] | select(."app-name" == "cmux" and (.["window-id"] as $id | ($before | index($id) | not))) | ."window-id"] | max // empty')"
        if [ -n "$new_id" ]; then
          ${aerospaceBin} move-node-to-workspace --window-id "$new_id" S
          exec ${aerospaceBin} focus --window-id "$new_id"
        fi
        sleep 0.1
      done

      exec ${aerospaceBin} workspace --auto-back-and-forth S
    '';
  };

  # Build on-window-detected rules as Nix attrsets
  appAssignments = concatLists (
    mapAttrsToList (ws: def:
      map (app: {
        "if".app-name-regex-substring = app;
        run = "move-node-to-workspace ${ws}";
      }) def.darwin
    ) kb.workspaces
  );

  persistentWs = workspaceNames ++ ["S"];
in {
  services.aerospace = {
    enable = true;
    settings = {
      config-version = 2;
      start-at-login = false; # Managed by launchd
      after-login-command = [];
      after-startup-command = [];
      persistent-workspaces = persistentWs;  # plain array: ['1', '2', ..., 'S']

      # BSP tiling (closest to Hyprland dwindle)
      default-root-container-layout = "tiles";
      default-root-container-orientation = "auto";

      # Match Hyprland gaps
      gaps = {
        inner = {horizontal = 5; vertical = 5;};
        outer = {left = 10; right = 10; top = 10; bottom = 10;};
      };

      # App assignments
      on-window-detected = appAssignments;

      # Keybindings — Hyper = ctrl-alt-cmd (physical Ctrl key via Karabiner)
      mode.main.binding = {
        # Workspace switching
        ctrl-alt-cmd-1 = "workspace 1";
        ctrl-alt-cmd-2 = "workspace 2";
        ctrl-alt-cmd-3 = "workspace 3";
        ctrl-alt-cmd-4 = "workspace 4";
        ctrl-alt-cmd-5 = "workspace 5";
        ctrl-alt-cmd-6 = "workspace 6";
        ctrl-alt-cmd-7 = "workspace 7";
        ctrl-alt-cmd-8 = "workspace 8";
        ctrl-alt-cmd-9 = "workspace 9";
        ctrl-alt-cmd-0 = "workspace 10";
        # Workspace cycling (arrow keys — matches macOS Ctrl+arrows convention)
        ctrl-alt-cmd-left = "exec-and-forget ${workspaceCyclePrev}/bin/aerospace-workspace-prev";
        ctrl-alt-cmd-right = "exec-and-forget ${workspaceCycleNext}/bin/aerospace-workspace-next";

        # Move window to workspace
        ctrl-alt-cmd-shift-1 = "move-node-to-workspace 1";
        ctrl-alt-cmd-shift-2 = "move-node-to-workspace 2";
        ctrl-alt-cmd-shift-3 = "move-node-to-workspace 3";
        ctrl-alt-cmd-shift-4 = "move-node-to-workspace 4";
        ctrl-alt-cmd-shift-5 = "move-node-to-workspace 5";
        ctrl-alt-cmd-shift-6 = "move-node-to-workspace 6";
        ctrl-alt-cmd-shift-7 = "move-node-to-workspace 7";
        ctrl-alt-cmd-shift-8 = "move-node-to-workspace 8";
        ctrl-alt-cmd-shift-9 = "move-node-to-workspace 9";
        ctrl-alt-cmd-shift-0 = "move-node-to-workspace 10";
        # Move window to adjacent workspace (shift+arrows)
        ctrl-alt-cmd-shift-left = "exec-and-forget ${moveToWorkspacePrev}/bin/aerospace-move-to-workspace-prev";
        ctrl-alt-cmd-shift-right = "exec-and-forget ${moveToWorkspaceNext}/bin/aerospace-move-to-workspace-next";

        # Window focus (comma/period)
        ctrl-alt-cmd-comma = "focus left";
        ctrl-alt-cmd-period = "focus right";
        ctrl-alt-cmd-down = "focus down";
        ctrl-alt-cmd-up = "focus up";

        # Window movement (comma/period + shift, and up/down + shift)
        ctrl-alt-cmd-shift-comma = "move left";
        ctrl-alt-cmd-shift-period = "move right";
        ctrl-alt-cmd-shift-down = "move down";
        ctrl-alt-cmd-shift-up = "move up";

        # Window state
        ctrl-alt-cmd-f = "fullscreen";
        ctrl-alt-cmd-space = "layout floating tiling";
        ctrl-alt-cmd-w = "close";
        ctrl-alt-cmd-l = "exec-and-forget ${lockScreen}/bin/aerospace-lock-screen";

        # Launch terminal
        ctrl-alt-cmd-enter = "exec-and-forget open -a cmux";

        # App launcher (Raycast)
        ctrl-alt-cmd-d = "exec-and-forget open -a Raycast";

        # File manager
        ctrl-alt-cmd-e = "exec-and-forget open -a Finder";

        # Scratch workspace toggle
        ctrl-alt-cmd-backtick = "exec-and-forget ${scratchTerminal}/bin/aerospace-scratch-terminal";
      };
    };
  };
}
