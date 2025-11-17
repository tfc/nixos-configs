{ pkgs, ... }:

{
  imports = [ ./desktop.nix ];

  home.packages = with pkgs; [
    cheese
    eog
    gnome-tweaks
    gnome-firmware
  ];

  programs.gnome-terminal = {
    enable = true;
    themeVariant = "dark";
    showMenubar = false;
    profile.e16104d4-a1f9-4c30-9f18-129377deb2f2 = {
      default = true;
      visibleName = "Default";
    };
  };
}
