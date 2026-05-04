{
  lib,
  runCommand,
  makeWrapper,
  claude-top,
  play-ready-sound,
}:

runCommand "claude-top-sound" {
  nativeBuildInputs = [ makeWrapper ];
} ''
  mkdir -p $out/bin
  makeWrapper ${lib.getExe claude-top} $out/bin/claude-top-sound \
    --add-flags "--on-idle ${lib.getExe play-ready-sound}"
''
