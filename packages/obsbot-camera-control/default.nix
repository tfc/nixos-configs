{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  qt6,
  autoPatchelfHook,
  lsof,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "obsbot-camera-control";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "aaronsb";
    repo = "obsbot-camera-control";
    rev = "v${finalAttrs.version}";
    hash = "sha256-Q9Y+TpD0W0CdFYrDNfi5CvF9crViCiSzc+nJUBh6MGI=";
  };

  nativeBuildInputs = [
    cmake
    qt6.wrapQtAppsHook
    autoPatchelfHook
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtmultimedia
    stdenv.cc.cc.lib
  ];

  qtWrapperArgs = [
    "--prefix PATH : ${lib.makeBinPath [ lsof ]}"
  ];

  installPhase = ''
    runHook preInstall

    install -Dm755 ../bin/obsbot-gui $out/bin/obsbot-gui
    install -Dm755 ../bin/obsbot-cli $out/bin/obsbot-cli

    install -Dm755 ../sdk/lib/libdev.so.1.0.2 $out/lib/libdev.so.1.0.2
    ln -s libdev.so.1.0.2 $out/lib/libdev.so.1
    ln -s libdev.so.1.0.2 $out/lib/libdev.so

    install -Dm644 ../obsbot-control.desktop \
      $out/share/applications/obsbot-control.desktop
    install -Dm644 ../resources/icons/camera.svg \
      $out/share/icons/hicolor/scalable/apps/obsbot-control.svg

    runHook postInstall
  '';

  preFixup = ''
    patchelf --remove-rpath $out/bin/obsbot-gui $out/bin/obsbot-cli
  '';

  meta = {
    description = "Native Qt6 control application for OBSBOT cameras on Linux";
    homepage = "https://github.com/aaronsb/obsbot-camera-control";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "obsbot-gui";
  };
})
