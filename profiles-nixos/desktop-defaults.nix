{
  imports = [
    ./applicative-systems-customization.nix
    ./desktop-responsiveness.nix
    ./traynix.nix
  ];

  customization.gdm-logo.enable = true;
  customization.gnome-background.enable = true;

  services.bootvine.enable = true;
  services.traynix.enable = true;
}
