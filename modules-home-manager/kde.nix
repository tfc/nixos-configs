{ pkgs, ... }:

{
  imports = [ ./desktop.nix ];

  # Plasma already ships gwenview/okular/dolphin/spectacle/kate/discover system
  # wide, and breeze-gtk + kde-gtk-config theme the GTK apps from desktop.nix.
  # Setting gtk.* here would fight kde-gtk-config: home-manager makes
  # ~/.config/gtk-3.0/settings.ini a read-only store symlink, which is the exact
  # path kde-gtk-config's kded daemon writes.
  home.packages = [ pkgs.kdePackages.kamoso ];
}
