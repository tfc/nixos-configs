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
              {
                # Same curve as the former OBS chain (+3 dB gain, then 5:1 above -26 dB).
                # Makeup gain sets the overall loudness: +1 dB here ≈ +1 LU in the recording.
                type = "ladspa";
                name = "comp";
                plugin = "${pkgs.ladspaPlugins}/lib/ladspa/sc4m_1916.so";
                label = "sc4m";
                control = {
                  "RMS/peak" = 1.0;
                  "Attack time (ms)" = 5;
                  "Release time (ms)" = 150;
                  "Threshold level (dB)" = -29;
                  "Ratio (1:n)" = 5;
                  "Knee radius (dB)" = 1;
                  "Makeup gain (dB)" = 15.5;
                };
              }
              {
                type = "ladspa";
                name = "limiter";
                plugin = "${pkgs.ladspaPlugins}/lib/ladspa/fast_lookahead_limiter_1913.so";
                label = "fastLookaheadLimiter";
                control = {
                  "Input gain (dB)" = 0;
                  "Limit (dB)" = -1.5;
                  "Release time (s)" = 0.1;
                };
              }
            ];
            links = [
              {
                output = "dfn:Audio Out";
                input = "comp:Input";
              }
              {
                output = "comp:Output";
                input = "limiter:Input 1";
              }
            ];
            # The limiter is stereo; use one channel of it for the mono mic.
            inputs = [ "dfn:Audio In" ];
            outputs = [ "limiter:Output 1" ];
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
