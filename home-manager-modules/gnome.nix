{ pkgs, ... }:

{
  imports = [ ./desktop.nix ];

  home.packages = with pkgs; [
    gnome3.cheese
    gnome3.eog
    gnome3.evince
    gnome3.gnome-tweaks
  ];

  programs.gnome-terminal = {
    enable = true;
    themeVariant = "dark";
    showMenubar = false;
    profile.default = {
      default = true;
      visibleName = "Default";
    };
  };
}
