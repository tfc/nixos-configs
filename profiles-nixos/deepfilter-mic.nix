{ pkgs, ... }:

{
  # Virtual mic "Profile (DeepFilter)": the Sennheiser Profile run through DeepFilterNet.
  # A low attenuation limit keeps the voice intact while typing: clicks overlapping speech
  # aren't removed at any setting, but higher limits start chopping the voice instead.
  services.pipewire.extraConfig.pipewire."99-deepfilter-mic" = {
    "context.modules" = [
      {
        name = "libpipewire-module-filter-chain";
        args = {
          "node.description" = "Profile (DeepFilter)";
          "media.name" = "Profile (DeepFilter)";
          "audio.rate" = 48000; # DeepFilterNet only works at 48 kHz
          "filter.graph" = {
            nodes = [
              {
                type = "ladspa";
                name = "dfn";
                plugin = "${pkgs.deepfilternet}/lib/ladspa/libdeep_filter_ladspa.so";
                label = "deep_filter_mono";
                control = {
                  "Attenuation Limit (dB)" = 10;
                };
              }
            ];
          };
          "capture.props" = {
            "node.name" = "capture.deepfilter_mic";
            "node.passive" = true;
            "audio.position" = [ "MONO" ];
            "target.object" = "alsa_input.usb-Sennheiser_Sennheiser_Profile_0523021441-00.mono-fallback";
          };
          "playback.props" = {
            "node.name" = "deepfilter_mic";
            "media.class" = "Audio/Source";
            "audio.position" = [ "MONO" ];
          };
        };
      }
    ];
  };
}
