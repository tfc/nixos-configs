{
  lib,
  stdenv,
  writeShellApplication,
  vorbis-tools,
  pulseaudio,
  coreutils,
  findutils,
}:

writeShellApplication {
  name = "play-ready-sound";
  runtimeInputs =
    lib.optionals stdenv.hostPlatform.isLinux [
      vorbis-tools
      pulseaudio
    ];
  text = ''
    sounds_dir=${./sounds}
    file=$(find "$sounds_dir" -name '*.ogg' | shuf -n 1)
    ${
      if stdenv.hostPlatform.isDarwin then
        ''exec /usr/bin/afplay "$file"''
      else
        ''oggdec -Q -o - "$file" | paplay''
    }
  '';
}
