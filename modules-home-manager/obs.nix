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

      obs-studio-plugins = prev.obs-studio-plugins // {
        # 3.2.1 fails against OBS 32 (deprecated obs_properties_add_button
        # + -Werror). Fixed on master, not yet released.
        obs-move-transition = prev.obs-studio-plugins.obs-move-transition.overrideAttrs (_: {
          version = "3.2.1-unstable-2026-10-04";
          src = prev.fetchFromGitHub {
            owner = "exeldro";
            repo = "obs-move-transition";
            rev = "64590490d87d93cc03baf0b35b90709468d9fb03";
            hash = "sha256-GOXNUwA2ASzDHMjsXSdUYQzqOtEBwmrr3oz5TXueKjY=";
          };
        });
        # master contains an OBS 32 fix (struct offset) not in 1.8.1, but
        # still calls the deprecated obs_properties_add_button with -Werror.
        obs-replay-source = prev.obs-studio-plugins.obs-replay-source.overrideAttrs (_: {
          version = "1.8.1-unstable-2026-09-23";
          src = prev.fetchFromGitHub {
            owner = "exeldro";
            repo = "obs-replay-source";
            rev = "842a48eaf74fdaa2a3236ba30c42cf574359970f";
            hash = "sha256-ZIG+jkq7TiZ+d+bektimPRg4E0YQPUjpowotDJHuigQ=";
          };
          env.NIX_CFLAGS_COMPILE = "-Wno-error=deprecated-declarations";
        });
        # With cudaSupport, OpenCV's CMake config does find_package(CUDAToolkit),
        # which needs nvcc at build time. Not a source issue; 1.36.1 is latest.
        advanced-scene-switcher = prev.obs-studio-plugins.advanced-scene-switcher.overrideAttrs (old: {
          nativeBuildInputs = old.nativeBuildInputs ++ [ prev.cudaPackages.cuda_nvcc ];
          buildInputs = old.buildInputs ++ [ prev.cudaPackages.cuda_cudart ];
        });
        # Still broken on master (2026-10-05), so just relax -Werror.
        obs-shaderfilter = prev.obs-studio-plugins.obs-shaderfilter.overrideAttrs (_: {
          env.NIX_CFLAGS_COMPILE = "-Wno-error=discarded-qualifiers -Wno-error=deprecated-declarations";
        });
      };
    }
  );
in
{
  home.packages = with pkgs'; [
    kdePackages.kdenlive
    losslesscut-bin
    shotcut

    obs-cmd
    streamcontroller
    wmctrl

    (wrapOBS {
      plugins = with obs-studio-plugins; [
        advanced-scene-switcher
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
