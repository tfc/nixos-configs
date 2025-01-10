{ pkgs, ... }:

{
  home.packages = with pkgs; [
    kdenlive
    losslesscut-bin
    shotcut
    (wrapOBS {
      plugins = with obs-studio-plugins; [
        obs-backgroundremoval
        obs-composite-blur
        droidcam-obs
        obs-gstreamer
        obs-move-transition
        obs-multi-rtmp
        obs-nvfbc
        obs-pipewire-audio-capture
        obs-replay-source
        obs-shaderfilter
        wlrobs
      ];
    })
  ];
}
