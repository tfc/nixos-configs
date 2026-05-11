{ pkgs, ... }:

{
  home.packages = with pkgs; [
    kdePackages.kdenlive
    losslesscut-bin
    shotcut

    obsbot-camera-control
    tiny2

    (wrapOBS {
      plugins = with obs-studio-plugins; [
        advanced-scene-switcher
        droidcam-obs
        obs-backgroundremoval
        obs-composite-blur
        obs-gstreamer
        obs-media-controlss
        obs-move-transition
        obs-multi-rtmp
        obs-nvfbc
        obs-pipewire-audio-capture
        obs-replay-source
        obs-shaderfilter
        obs-teleport
        wlrobs
      ];
    })
  ];
}
