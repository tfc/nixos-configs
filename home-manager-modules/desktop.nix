{ pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    chromium
    deja-dup
    foliate
    #    foxitreader # disabled because of qtwebkit
    gimp
    gitg
    google-chrome
    inkscape
    libreoffice
    mupdf
    (wrapOBS {
      plugins = with obs-studio-plugins; [
        obs-gstreamer
        obs-move-transition
        obs-multi-rtmp
        wlrobs
      ];
    })
    #obsidian
    retext
    signal-desktop
    spotify
    teamspeak_client # write a wrapper that adds  QT_XCB_GL_INTEGRATION=none
    vlc
    xournalpp
  ];

  manual.html.enable = true;

  programs.firefox = {
    enable = true;
    #    package = pkgs.firefox-bin;
    profiles = {
      myprofile = {
        settings = {
          "browser.sessionstore.interval" = 60000;
          "browser.tabs.animate" = false;
          "browser.download.animateNotifications" = false;
          "browser.urlbar.maxRichResults" = 5;
          "dom.battery.enabled" = false;
          "extensions.pocket.enabled" = false;
          "general.smoothScroll" = false;
          "network.prefetch-next" = false;
          "privacy.trackingprotection.enabled" = true;
          "toolkit.cosmeticAnimations.enabled" = false;

          # performance suggestions from https://gist.github.com/0XDE57/fbd302cef7693e62c769
          "layout.frame_rate.precise" = true;
          "webgl.force-enabled" = true;
          "layers.acceleration.force-enabled" = true;
          "layers.offmainthreadcomposition.enabled" = true;
          "layers.offmainthreadcomposition.async-animations" = true;
          "layers.async-video.enabled" = true;
          "html5.offmainthread" = true;
        };
      };
    };
  };

  programs.brave = {
    enable = true;
    extensions = [
      "cfhdojbkjhnklbpkdaibdccddilifddb" # adblock plus
      "gcbommkclmclpchllfjekcdonpmejbdp" # https everywhere
      "hjdoplcnndgiblooccencgcggcoihigg" # Terms of Service; Didn’t Read
      "kghbmcgihmefcbjlfiafjcigdcbmecbf" # heylogin
    ];
  };
}
