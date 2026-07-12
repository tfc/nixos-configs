{
  flakeInputs,
  ...
}:

{
  imports = [
    flakeInputs.traynix.nixosModules.default
  ];

  nixpkgs.overlays = [
    flakeInputs.traynix.overlays.default
    flakeInputs.traynix.overlays.naersk
  ];

  services.traynix.enable = true;
}
