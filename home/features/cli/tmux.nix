# Tmux configuration with Dracula theme, session logging, persistence, and emacs copy-mode.
# Prefix: Ctrl+] primary, Ctrl+A backup. Shell stays in emacs mode via bindkey -e in zsh.
# Logging plugin compensates for Ghostty lacking auto-logging (GitHub #5209).
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.cli.tmux;
in {
  options.features.cli.tmux.enable = mkEnableOption "tmux terminal multiplexer";

  config = mkIf cfg.enable {
    programs.tmux = {
      enable = true;
      prefix = "C-]";
      mouse = true;
      historyLimit = 100000;
      baseIndex = 1;
      escapeTime = 0;
      keyMode = "emacs"; # shell and copy-mode both use emacs-style movement
      terminal = "tmux-256color";
      sensibleOnTop = true;

      plugins = with pkgs.tmuxPlugins; [
        sensible
        {
          # Dracula status bar with system info segments
          plugin = dracula;
          extraConfig = ''
            set -g @dracula-show-powerline true
            set -g @dracula-plugins "cpu-usage ram-usage battery"
            set -g @dracula-show-left-icon session
            set -g @dracula-border-contrast true
            set -g @dracula-show-flags true
            set -g @dracula-refresh-rate 5
            set -g @dracula-show-empty-plugins false
          '';
        }
        yank
        pain-control
        {
          # Session logging to ~/tmux-logs/ -- fills Ghostty's logging gap
          # Auto-starts logging on every new pane
          plugin = logging;
          extraConfig = ''
            set -g @logging-path "$HOME/tmux-logs"
            set -g @screen-capture-path "$HOME/tmux-logs"
            set -g @save-complete-history-path "$HOME/tmux-logs"
            set -g @logging-auto "on"
          '';
        }
        {
          # Save/restore tmux sessions across reboots
          plugin = resurrect;
          extraConfig = ''
            set -g @resurrect-capture-pane-contents 'on'
            set -g @resurrect-strategy-nvim 'session'
          '';
        }
        {
          # Auto-save sessions every 15 minutes, auto-restore on tmux start
          plugin = continuum;
          extraConfig = ''
            set -g @continuum-restore 'on'
            set -g @continuum-save-interval '15'
          '';
        }
        {
          # Fuzzy-find sessions, windows, panes, and commands
          plugin = tmux-fzf;
          extraConfig = ''
            TMUX_FZF_LAUNCH_KEY="f"
          '';
        }
        {
          # Quick-copy visible text: URLs, paths, hashes, IPs
          plugin = tmux-thumbs;
          extraConfig = ''
            set -g @thumbs-key Space
          '';
        }
      ];

      extraConfig = ''
        # Keep Ctrl+A as a transitional backup prefix while Ctrl+] becomes primary.
        set -g prefix2 C-a
        bind C-a send-prefix

        # Split panes with | and - (more intuitive than % and ")
        bind | split-window -h -c "#{pane_current_path}"
        bind - split-window -v -c "#{pane_current_path}"

        # Window navigation with upstream-style Shift+Left/Right and Shift+Down.
        bind -n S-Left previous-window
        bind -n S-Right next-window
        bind -n S-Down new-window -c "#{pane_current_path}"

        # Pane navigation with Prefix+arrows
        bind Left select-pane -L
        bind Right select-pane -R
        bind Up select-pane -U
        bind Down select-pane -D

        # Pane swapping with Prefix+, / Prefix+.
        bind comma swap-pane -t :-
        bind period swap-pane -t :+

        # Pane resizing with Prefix+Shift+arrows
        bind S-Left resize-pane -L 2
        bind S-Right resize-pane -R 2
        bind S-Up resize-pane -U 2
        bind S-Down resize-pane -D 2

        # New windows/panes inherit current path
        bind c new-window -c "#{pane_current_path}"

        # Terminal overrides for true color and Ghostty
        set -ga terminal-overrides ",xterm-256color:Tc"
        set -ga terminal-overrides ",ghostty:Tc"

        # Pane border labels and client sizing
        set -g pane-border-status top
        setw -g aggressive-resize on

        # Renumber windows when one is closed
        set -g renumber-windows on

        # Activity monitoring
        setw -g monitor-activity on
        set -g visual-activity off

        # Quick reload config
        bind r source-file ~/.config/tmux/tmux.conf \; display "Config reloaded!"
      '';
    };
  };
}
