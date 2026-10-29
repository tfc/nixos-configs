{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  autoPatchelfHook,
  libxkbcommon,
  wayland,
  libGL,
  vulkan-loader,
  fontconfig,
  freetype,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "tiny2";
  version = "0-unstable-2026-03-29";

  src = fetchFromGitHub {
    owner = "cgevans";
    repo = "tiny2";
    rev = "a5425b802f33d57aa73c520fad5c1a0e0c9bd0d3";
    hash = "sha256-BlLfRuWSyk99egkwZu8AiuWBJ91Gr0FrpanFoHluHlk=";
  };

  cargoLock.lockFile = "${finalAttrs.src}/Cargo.lock";

  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [
    libxkbcommon
    wayland
    libGL
    vulkan-loader
    fontconfig
    freetype
    stdenv.cc.cc.lib
  ];

  appendRunpaths = map (p: "${lib.getLib p}/lib") [
    libxkbcommon
    wayland
    libGL
    vulkan-loader
    fontconfig
    freetype
  ];

  postInstall = ''
    mv $out/bin/obsbot-gui $out/bin/tiny2-gui
    mv $out/bin/obsbot-osc-server $out/bin/tiny2-osc-server
  '';

  meta = {
    description = "Iced-based Linux GUI controller for the OBSBot Tiny 2 webcam";
    homepage = "https://github.com/cgevans/tiny2";
    license = lib.licenses.eupl12;
    platforms = lib.platforms.linux;
    mainProgram = "tiny2-gui";
  };
})
