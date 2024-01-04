{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    git
    nixos-rebuild
    vim
  ];

  nix.linux-builder.enable = true;

  services.nix-daemon.enable = true;
  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [
        "flakes"
        "nix-command"
        "repl-flake"
      ];
      #sandbox = true; # breaks many builds
      trusted-users = [ "@admin" ];
    };
    nixPath = lib.mkForce [ "nixpkgs=${pkgs.path}" ];
  };

  nixpkgs.config.allowUnfree = true;

  security.pam.enableSudoTouchIdAuth = true;
  programs.zsh.enable = true;

  users.users.tfc.home = "/Users/tfc";

  fonts.fontDir.enable = true;
  fonts.fonts = with pkgs; [
    powerline-fonts
  ];

  system.stateVersion = 4;
}
