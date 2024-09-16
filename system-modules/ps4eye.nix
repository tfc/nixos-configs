{ pkgs, lib, ... }:

let
  python3 = pkgs.python3.withPackages (p: [ p.pyusb ]);
  ps4eye = pkgs.fetchFromGitHub {
    owner = "longjie";
    repo = "ps4eye";
    rev = "ec11823e91e138aeeb7f15c0e70d1934604e1337";
    hash = "sha256-fXqcgKUyekfRnPGK42jm5SWiK14nef6G8xicp0kdTPU=";
  };
  ps4eyeInit = pkgs.runCommand "ps4eye-init" { buildInputs = [ python3 ]; } ''
    mkdir -p $out/share $out/bin
    cp ${ps4eye}/script/firmware.bin $out/share/
    cp ${ps4eye}/script/ps4eye_init.py $out/bin/ps4eye-init
    patchShebangs $out/bin
    sed -i "s|script_dir + \"|\"$out/share|" $out/bin/ps4eye-init
  '';
in

{
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="05a9", ATTRS{idProduct}=="0580" RUN+="${ps4eyeInit}/bin/ps4eye-init"
  '';
}
