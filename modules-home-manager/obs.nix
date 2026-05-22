{ pkgs, ... }:

let
  # nixpkgs ships StreamController 1.5.0-beta.13, which misbehaves for us.
  # Bump to beta.14. Upstream hardcodes the rev in the nixpkgs derivation
  # (it cuts multiple releases per version), so we override src + version.
  pkgs' = pkgs.extend (
    _: prev: {
      streamcontroller = prev.streamcontroller.overrideAttrs (_: {
        version = "1.5.0-beta.14";
        src = prev.fetchFromGitHub {
          owner = "StreamController";
          repo = "StreamController";
          rev = "12052dec15d0e0948032c7ec11eff2da0d109106";
          hash = "sha256-JGJc7bj58oZwvtExSv+tv7Ug84RYdEkcMBI3ZmqpaKY=";
        };
      });
    }
  );
in
{
  home.packages = with pkgs'; [
    kdePackages.kdenlive
    losslesscut-bin
    shotcut

    obsbot-camera-control
    obsbot-tiny-2-control
    tiny2

    obs-cmd
    streamcontroller
    wmctrl

    (wrapOBS {
      plugins = with obs-studio-plugins; [
        # > CMake Error at /nix/store/v2i1hgv567g3v91im5x4g5bff52143i0-cmake-4.1.2/share/cmake-4.1/Modules/FindCUDAToolkit.cmake:890 (message):
        #       >   Could not find nvcc, please set CUDAToolkit_ROOT.
        #       > Call Stack (most recent call first):
        #       >   /nix/store/kyaja74g8jl4drgma0gmqadj33bwg2d2-opencv-4.13.0/lib/cmake/opencv4/OpenCVConfig.cmake:86 (find_package)
        #       >   /nix/store/kyaja74g8jl4drgma0gmqadj33bwg2d2-opencv-4.13.0/lib/cmake/opencv4/OpenCVConfig.cmake:108 (find_host_package)
        #       >   plugins/video/CMakeLists.txt:8 (find_package)

        # advanced-scene-switcher
        droidcam-obs
        obs-backgroundremoval
        obs-composite-blur
        obs-gstreamer
        obs-media-controls
        obs-move-transition
        obs-multi-rtmp
        obs-pipewire-audio-capture
        obs-replay-source
        obs-shaderfilter
        obs-teleport
        wlrobs
      ];
    })
  ];

}
