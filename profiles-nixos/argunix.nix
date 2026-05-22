{
  flakeInputs,
  ...
}:

{
  imports = [
    flakeInputs.argunix.nixosModules.argunix-builder
  ];

  nixpkgs.overlays = [
    flakeInputs.argunix.overlays.default
  ];

  services.argunix-builder = {
    enable = true;
    argunixHost = "argunix.nix-consulting.net";
    argunixPort = 45678;
    enrollmentTokenFile = "/tmp/argunix-token";
  };
}
