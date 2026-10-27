{
  lib,
  python3Packages,
  bash,
  fontconfig,
  ruff,
  ty,
}:

python3Packages.buildPythonApplication {
  pname = "streamdeck-toml";
  version = "0.1.0";
  pyproject = true;

  src = lib.fileset.toSource {
    root = ./.;
    fileset = lib.fileset.unions [
      ./pyproject.toml
      ./streamdeck.py
    ];
  };

  build-system = [ python3Packages.setuptools ];

  dependencies = with python3Packages; [
    cairosvg
    pillow
    streamdeck
  ];

  # Key commands run through sh; fc-match resolves font patterns like "DejaVu Sans:bold".
  # Both must work in a systemd user service, whose PATH is minimal.
  makeWrapperArgs = [
    "--prefix"
    "PATH"
    ":"
    (lib.makeBinPath [
      bash
      fontconfig
    ])
  ];

  nativeCheckInputs = [
    ruff
    ty
  ];
  checkPhase = ''
    runHook preCheck
    ruff format --check --no-cache .
    ruff check --no-cache .
    ty check --python ${python3Packages.python.interpreter} .
    runHook postCheck
  '';

  pythonImportsCheck = [ "streamdeck" ];

  meta = {
    description = "Drive an Elgato Stream Deck from a TOML file";
    license = lib.licenses.mit;
    mainProgram = "streamdeck-toml";
    platforms = lib.platforms.linux;
  };
}
