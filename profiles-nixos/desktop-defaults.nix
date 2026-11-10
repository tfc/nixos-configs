{ flakeInputs, self, ... }:

{
  imports = [
    self.nixosProfiles.applicative-systems-customization
    self.nixosProfiles.desktop-responsiveness
    flakeInputs.bootvine.nixosModules.default
    ./traynix.nix
  ];

  customization.gdm-logo.enable = true;
  customization.gnome-background.enable = true;

  services.bootvine.enable = true;
  services.traynix.enable = true;
}
