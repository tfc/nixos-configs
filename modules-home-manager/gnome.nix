{ pkgs, ... }:

{
  imports = [ ./desktop.nix ];

  # Hold Super and drag anywhere on a window to move (left button) or resize
  # (right button). Pinned here because the per-user dconf value drifts back to
  # GNOME's default (resize-with-right-button = false) across shell upgrades.
  dconf.settings."org/gnome/desktop/wm/preferences" = {
    mouse-button-modifier = "<Super>";
    resize-with-right-button = true;
  };

  home.packages = with pkgs; [
    cheese
    eog
    gnome-tweaks
    gnome-firmware
    gnomeExtensions.appindicator
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
