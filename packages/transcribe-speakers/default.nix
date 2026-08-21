{
  lib,
  writeShellApplication,
  fetchurl,
  whisper-cpp,
  pulseaudio,
  coreutils,
  gawk,
  name ? "transcribe-speakers",
  variant ? "large-v3-turbo",
}:

let
  models = {
    # ~2 GB VRAM and 27x realtime on the RTX 2080 Super, multilingual (`-l de`,
    # `-tr`). Comfortable next to Ollama in the 8 GB the GPU has.
    "large-v3-turbo" = {
      url = "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large-v3-turbo.bin";
      hash = "sha256-H8cPd0046xaZk6w5Huo1fvR8iHV+9y7llDh5t+jivGk=";
    };
    # 148MB, realtime on CPU alone — for when the GPU is busy.
    "base.en" = {
      url = "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.en.bin";
      hash = "sha256-oDd5yG3zMjB19eeWyyzlAp8A7Ihp7uP9+4l6/jbG0AI=";
    };
    # tinydiarize fine-tune: appends [SPEAKER_TURN] where the speaker changes.
    # Marks turns only, never identities, and exists for small.en alone — so it
    # trades away large-v3-turbo's transcript quality for the markers.
    "small.en-tdrz" = {
      url = "https://huggingface.co/akashmjn/tinydiarize-whisper.cpp/resolve/main/ggml-small.en-tdrz.bin";
      hash = "sha256-zqw+wG0dmO9xrsZlKDVkYxBV/WEpt52OG+T5zDPMVLQ=";
    };
  };
  model = fetchurl models.${variant};
  tdrz = lib.optionalString (lib.hasSuffix "-tdrz" variant) " -tdrz";
in

writeShellApplication {
  inherit name;
  runtimeInputs = [
    whisper-cpp
    pulseaudio
    coreutils
    gawk
  ];
  # whisper-stream captures through SDL, which only ever opens the *default*
  # PulseAudio source (it passes the device name explicitly, so PULSE_SOURCE
  # is ignored) and never lists monitor sources. So: start it, then move its
  # stream over to the default sink's monitor. That keeps the change local to
  # this one stream — flipping the global default source would hand desktop
  # audio to whatever grabs the mic next, e.g. the meeting itself.
  text = ''
    whisper-stream -m ${model}${tdrz} "$@" &
    pid=$!
    trap 'kill $pid 2>/dev/null' EXIT

    # Ours is the newest whisper-stream stream, hence the highest id.
    for _ in $(seq 40); do
      stream=$(pactl list source-outputs | awk '
        /^Source Output #/                    { id = substr($3, 2) }
        /application\.name = "whisper-stream"/ { if (id > last) last = id }
        END                                    { print last }')
      [ -n "$stream" ] && break
      sleep 0.5
    done

    if ! pactl move-source-output "$stream" "$(pactl get-default-sink).monitor"; then
      echo "${name}: could not capture speaker output" >&2
      exit 1
    fi

    wait $pid
  '';
}
