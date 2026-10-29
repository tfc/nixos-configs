{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  python3,
  makeWrapper,
}:

let
  pythonEnv = python3.withPackages (ps: [
    ps.libusb1
    ps.shiny
  ]);
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "obsbot-tiny-2-control";
  version = "0-unstable-2024-09-30";

  src = fetchFromGitHub {
    owner = "mitchelloharawild";
    repo = "obsbot-tiny-2-control";
    rev = "4d2ef3c6fe7897f49499934e8d441fc98e8385e8";
    hash = "sha256-W0uK8iClRpHNh41J0XOkNv+SlmeWj4cZeIT7jLYfhvE=";
  };

  nativeBuildInputs = [ makeWrapper ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    libdir=$out/share/obsbot-tiny-2-control
    install -Dm644 obsbot.py $libdir/obsbot.py
    install -Dm644 app.py $libdir/app.py

    # CLI: python obsbot.py -ai <mode>
    makeWrapper ${pythonEnv}/bin/python3 $out/bin/obsbot-tiny-2-control \
      --add-flags "$libdir/obsbot.py"

    # Shiny app (app.py imports the obsbot module from the same directory),
    # intended as a custom browser dock in OBS Studio.
    makeWrapper ${pythonEnv}/bin/shiny $out/bin/obsbot-tiny-2-control-app \
      --add-flags "run --launch-browser $libdir/app.py" \
      --prefix PYTHONPATH : "$libdir"

    runHook postInstall
  '';

  meta = {
    description = "Python controls for setting the AI tracking mode on the OBSBOT Tiny 2 webcam";
    homepage = "https://github.com/mitchelloharawild/obsbot-tiny-2-control";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "obsbot-tiny-2-control";
  };
})
