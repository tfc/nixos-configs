{
  flakeInputs,
  ...
}:

{
  imports = [ flakeInputs.traynix.nixosModules.default ];
  nixpkgs.overlays = [ flakeInputs.traynix.overlays.default ];

  services.traynix.enable = true;
}
