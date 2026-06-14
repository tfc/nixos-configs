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
    flakeInputs.traynix.inputs.naersk.overlays.default
    flakeInputs.traynix.inputs.gcan.overlays.default
  ];
}
