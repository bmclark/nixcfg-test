# Chromium: fallback browser for sites broken by Firefox privacy hardening.
# Minimal privacy flags + essential extensions only.
# Linux-only: pkgs.chromium is not available on aarch64-darwin.
# macOS uses Google Chrome cask via darwin/common/homebrew.nix instead.
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.desktop.chromium;
in {
  options.features.desktop.chromium.enable = mkEnableOption "enable Chromium browser";

  config = mkIf (cfg.enable && pkgs.stdenv.isLinux) {
    programs.chromium = {
      enable = true;
      extensions = [
        # Bitwarden password manager
        {id = "nngceckbapebfimnlniiiahkandclblb";}
        # uBlock Origin
        {id = "cjpalhdlnbpafiamejdnhcphjbkeiagm";}
        # Dracula theme
        {id = "gfapcejdoghpoidkfodoiiffaaibpaem";}
        # Dark Reader
        {id = "eimadpbcbfnmbkopoojfekhnkhdbieeh";}
        # xBrowserSync: bookmark sync (matches Firefox)
        {id = "lcbjdhceifofjlpecfpeimnnphbcjgnc";}
      ];
      commandLineArgs = [
        # Privacy: disable Google service integrations
        "--disable-features=WebRtcAllowInputVolumeAdjustment"
        "--disable-sync"
        "--disable-background-networking"
        "--disable-client-side-phishing-detection"
        "--disable-default-apps"
        "--disable-breakpad"
        "--no-default-browser-check"
        "--disable-component-update" # prevent silent Google component downloads
        "--disable-domain-reliability" # no Google domain telemetry
        "--disable-translate" # no Google Translate phoning home

        # DNS-over-HTTPS via Quad9
        "--enable-features=DnsOverHttps"
        "--force-dark-mode"
      ];
    };
  };
}
