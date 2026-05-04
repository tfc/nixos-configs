{
  writeShellApplication,
  vorbis-tools,
  coreutils,
}:

writeShellApplication {
  name = "play-ready-sound";
  runtimeInputs = [
    vorbis-tools
    coreutils
  ];
  text = ''
    sounds_dir=${./sounds}
    file=$(find "$sounds_dir" -name '*.ogg' | shuf -n 1)
    exec ogg123 -q "$file"
  '';
}
