# Declarative git configuration with delta pager, switchable syntax theme, and common aliases.
# Identity: Bryan Clark <bryan@bclark.net>
{
  config,
  lib,
  pkgs,
  theme,
  ...
}:
with lib; let
  cfg = config.features.development.git;
in {
  options.features.development.git.enable = mkEnableOption "declarative git configuration";

  config = mkIf cfg.enable {
    programs.git = {
      enable = true;

      settings = {
        user = {
          name = "Bryan Clark";
          email = "bryan@bclark.net";
        };
        init.defaultBranch = "main";
        push.autoSetupRemote = true;
        pull.rebase = true;
        core.editor = "emacs";
        merge.conflictstyle = "diff3";
        diff.colorMoved = "default";
        rerere.enabled = true;

        alias = {
          st = "status";
          co = "checkout";
          br = "branch";
          ci = "commit";
          lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
          unstage = "reset HEAD --";
          last = "log -1 HEAD";
          amend = "commit --amend --no-edit";
          # AI-agent-friendly: auto-fixup staged changes into prior commits
          absorb = "absorb --and-rebase";
          # Syntax-aware diff via difftastic
          dft = "difftool";
        };
        # Use difftastic for `git dft` -- structural, syntax-aware diffs
        difftool.difftastic.cmd = ''difft "$LOCAL" "$REMOTE"'';
        diff.tool = "difftastic";
        difftool.prompt = false;
      };

      ignores = [
        ".DS_Store"
        ".direnv/"
        "result"
        "result-*"
      ];
    };

    # Delta: syntax-highlighted, side-by-side diffs with theme-aware colors.
    programs.delta = {
      enable = true;
      enableGitIntegration = true;
      options = {
        syntax-theme = theme.deltaThemeName;
        line-numbers = true;
        side-by-side = true;
        navigate = true;
      };
    };
  };
}
